#!/usr/bin/env python3
"""
Convert Xcode coverage JSON (from xcrun xccov view --json) to Cobertura XML format.

This script is used in GitLab CI to generate coverage reports that can be used
for MR coverage comparison.

Usage:
    python3 xccov-to-cobertura.py coverage.json > cobertura.xml

    Or with xcresult directly:
    xcrun xccov view --report --json Result.xcresult | python3 xccov-to-cobertura.py - > cobertura.xml
"""

import json
import sys
import os
from xml.etree.ElementTree import Element, SubElement, tostring
from xml.dom import minidom
import time


def prettify(elem):
    """Return a pretty-printed XML string for the Element."""
    rough_string = tostring(elem, encoding='unicode')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")


def create_cobertura_xml(coverage_data, source_root=None):
    """
    Convert Xcode coverage JSON to Cobertura XML format.
    
    Args:
        coverage_data: Parsed JSON from xcrun xccov view --json
        source_root: Optional source root path for relative paths
    
    Returns:
        Cobertura XML Element
    """
    # Create root coverage element
    coverage = Element('coverage')
    coverage.set('version', '1.0')
    coverage.set('timestamp', str(int(time.time() * 1000)))
    
    # Initialize counters
    total_lines_valid = 0
    total_lines_covered = 0
    total_branches_valid = 0
    total_branches_covered = 0
    
    # Create packages element
    packages = SubElement(coverage, 'packages')
    
    # Process each target
    targets = coverage_data.get('targets', [])
    
    for target in targets:
        target_name = target.get('name', 'Unknown')
        
        # Skip test targets and system frameworks
        if 'Tests' in target_name or target_name.startswith('__'):
            continue
            
        # Include all non-test targets (Swift packages)
        # This works for any package name
        
        # Create package for this target
        package = SubElement(packages, 'package')
        package.set('name', target_name)
        package.set('complexity', '0')
        
        package_lines_valid = 0
        package_lines_covered = 0
        
        classes = SubElement(package, 'classes')
        
        # Process files in target
        files = target.get('files', [])
        
        for file_info in files:
            file_path = file_info.get('path', '')
            file_name = file_info.get('name', os.path.basename(file_path))
            
            # Skip non-Swift files
            if not file_name.endswith('.swift'):
                continue
            
            # Create class element (one per file)
            class_elem = SubElement(classes, 'class')
            class_elem.set('name', file_name.replace('.swift', ''))
            class_elem.set('filename', file_path if source_root is None else os.path.relpath(file_path, source_root))
            class_elem.set('complexity', '0')
            
            # Methods placeholder (Xcode doesn't provide function-level detail in JSON)
            methods = SubElement(class_elem, 'methods')
            
            # Process line coverage
            lines_elem = SubElement(class_elem, 'lines')
            
            # Get line coverage data
            line_coverage = file_info.get('lineCoverage', 0)
            covered_lines = file_info.get('coveredLines', 0)
            executable_lines = file_info.get('executableLines', 0)
            
            # If detailed line info is available, use it
            functions = file_info.get('functions', [])
            
            line_data = {}  # line_number -> hit_count
            
            for func in functions:
                # Get execution count (hits) for the function
                exec_count = func.get('executionCount', 0)
                line_number = func.get('lineNumber', 0)
                
                if line_number > 0:
                    line_data[line_number] = exec_count
            
            # Add line elements
            if line_data:
                for line_num, hits in sorted(line_data.items()):
                    line = SubElement(lines_elem, 'line')
                    line.set('number', str(line_num))
                    line.set('hits', str(hits))
                    line.set('branch', 'false')
            else:
                # Create synthetic line data from file coverage
                for i in range(1, executable_lines + 1):
                    line = SubElement(lines_elem, 'line')
                    line.set('number', str(i))
                    # Distribute covered lines across the file
                    hits = '1' if i <= covered_lines else '0'
                    line.set('hits', hits)
                    line.set('branch', 'false')
            
            # Update counters
            package_lines_valid += executable_lines
            package_lines_covered += covered_lines
            
            # Set class-level rates
            class_line_rate = covered_lines / executable_lines if executable_lines > 0 else 0
            class_elem.set('line-rate', f'{class_line_rate:.4f}')
            class_elem.set('branch-rate', '0')
        
        # Set package-level rates
        package_line_rate = package_lines_covered / package_lines_valid if package_lines_valid > 0 else 0
        package.set('line-rate', f'{package_line_rate:.4f}')
        package.set('branch-rate', '0')
        
        total_lines_valid += package_lines_valid
        total_lines_covered += package_lines_covered
    
    # Set root-level attributes
    line_rate = total_lines_covered / total_lines_valid if total_lines_valid > 0 else 0
    coverage.set('line-rate', f'{line_rate:.4f}')
    coverage.set('branch-rate', '0')
    coverage.set('lines-covered', str(total_lines_covered))
    coverage.set('lines-valid', str(total_lines_valid))
    coverage.set('branches-covered', str(total_branches_covered))
    coverage.set('branches-valid', str(total_branches_valid))
    coverage.set('complexity', '0')
    
    # Add sources element (optional, helps with path resolution)
    sources = SubElement(coverage, 'sources')
    source = SubElement(sources, 'source')
    source.text = source_root or '.'
    
    return coverage


def main():
    # Read input
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        if input_file == '-':
            coverage_json = sys.stdin.read()
        else:
            with open(input_file, 'r') as f:
                coverage_json = f.read()
    else:
        coverage_json = sys.stdin.read()
    
    # Parse JSON
    try:
        coverage_data = json.loads(coverage_json)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Get source root from environment or argument
    source_root = os.environ.get('SOURCE_ROOT', None)
    if len(sys.argv) > 2:
        source_root = sys.argv[2]
    
    # Convert to Cobertura XML
    cobertura = create_cobertura_xml(coverage_data, source_root)
    
    # Output XML
    xml_str = prettify(cobertura)
    
    # Add XML declaration and DOCTYPE
    output = '<?xml version="1.0" encoding="UTF-8"?>\n'
    output += '<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">\n'
    # Remove the XML declaration from prettified output (it adds its own)
    xml_lines = xml_str.split('\n')
    output += '\n'.join(xml_lines[1:])
    
    print(output)


if __name__ == '__main__':
    main()

