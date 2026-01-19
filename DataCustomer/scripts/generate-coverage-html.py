#!/usr/bin/env python3
"""
Generate HTML coverage report from Xcode coverage JSON.

This script creates a user-friendly HTML report for viewing code coverage,
which is published to GitLab Pages.

Usage:
    python3 generate-coverage-html.py coverage.json output_dir/
"""

import json
import sys
import os
from datetime import datetime


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Code Coverage Report</title>
    <style>
        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f5f5;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }}
        header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            text-align: center;
            margin-bottom: 30px;
            border-radius: 10px;
        }}
        header h1 {{
            font-size: 2.5rem;
            margin-bottom: 10px;
        }}
        header p {{
            font-size: 1.1rem;
            opacity: 0.9;
        }}
        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .summary-card {{
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }}
        .summary-card h3 {{
            font-size: 0.9rem;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 10px;
        }}
        .summary-card .value {{
            font-size: 2.5rem;
            font-weight: bold;
        }}
        .summary-card .value.good {{
            color: #22c55e;
        }}
        .summary-card .value.moderate {{
            color: #eab308;
        }}
        .summary-card .value.low {{
            color: #ef4444;
        }}
        .coverage-bar {{
            height: 8px;
            background: #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 10px;
        }}
        .coverage-bar-fill {{
            height: 100%;
            border-radius: 4px;
            transition: width 0.5s ease;
        }}
        .coverage-bar-fill.good {{
            background: linear-gradient(90deg, #22c55e, #16a34a);
        }}
        .coverage-bar-fill.moderate {{
            background: linear-gradient(90deg, #eab308, #ca8a04);
        }}
        .coverage-bar-fill.low {{
            background: linear-gradient(90deg, #ef4444, #dc2626);
        }}
        .files-section {{
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        .files-header {{
            padding: 20px;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        .files-header h2 {{
            font-size: 1.3rem;
        }}
        .search-box {{
            padding: 8px 16px;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            width: 250px;
        }}
        .files-table {{
            width: 100%;
            border-collapse: collapse;
        }}
        .files-table th {{
            text-align: left;
            padding: 12px 20px;
            background: #f9fafb;
            border-bottom: 1px solid #e5e7eb;
            font-weight: 600;
            color: #374151;
        }}
        .files-table td {{
            padding: 12px 20px;
            border-bottom: 1px solid #f3f4f6;
        }}
        .files-table tr:hover {{
            background: #f9fafb;
        }}
        .file-name {{
            font-family: 'SF Mono', Monaco, monospace;
            font-size: 0.9rem;
            color: #1f2937;
        }}
        .file-path {{
            font-size: 0.75rem;
            color: #9ca3af;
            margin-top: 2px;
        }}
        .coverage-cell {{
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .coverage-percent {{
            min-width: 60px;
            font-weight: 600;
        }}
        .mini-bar {{
            flex: 1;
            height: 6px;
            background: #e5e7eb;
            border-radius: 3px;
            min-width: 100px;
        }}
        .mini-bar-fill {{
            height: 100%;
            border-radius: 3px;
        }}
        footer {{
            text-align: center;
            padding: 30px;
            color: #6b7280;
            font-size: 0.9rem;
        }}
        @media (max-width: 768px) {{
            header h1 {{
                font-size: 1.8rem;
            }}
            .files-header {{
                flex-direction: column;
                gap: 15px;
            }}
            .search-box {{
                width: 100%;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>📊 Code Coverage</h1>
            <p>Generated on {timestamp}</p>
        </header>
        
        <div class="summary">
            <div class="summary-card">
                <h3>Total Coverage</h3>
                <div class="value {coverage_class}">{total_coverage}%</div>
                <div class="coverage-bar">
                    <div class="coverage-bar-fill {coverage_class}" style="width: {total_coverage}%"></div>
                </div>
            </div>
            <div class="summary-card">
                <h3>Lines Covered</h3>
                <div class="value">{covered_lines}</div>
            </div>
            <div class="summary-card">
                <h3>Total Lines</h3>
                <div class="value">{total_lines}</div>
            </div>
            <div class="summary-card">
                <h3>Files Analyzed</h3>
                <div class="value">{total_files}</div>
            </div>
        </div>
        
        <div class="files-section">
            <div class="files-header">
                <h2>File Coverage Details</h2>
                <input type="text" class="search-box" placeholder="Search files..." id="searchInput" onkeyup="filterTable()">
            </div>
            <table class="files-table" id="filesTable">
                <thead>
                    <tr>
                        <th>File</th>
                        <th>Lines</th>
                        <th style="width: 300px;">Coverage</th>
                    </tr>
                </thead>
                <tbody>
                    {file_rows}
                </tbody>
            </table>
        </div>
        
        <footer>
            <p>Coverage Report • {commit_info}</p>
        </footer>
    </div>
    
    <script>
        function filterTable() {{
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('filesTable');
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 1; i < rows.length; i++) {{
                const cells = rows[i].getElementsByTagName('td');
                if (cells.length > 0) {{
                    const text = cells[0].textContent.toLowerCase();
                    rows[i].style.display = text.includes(filter) ? '' : 'none';
                }}
            }}
        }}
    </script>
</body>
</html>
"""

FILE_ROW_TEMPLATE = """
<tr>
    <td>
        <div class="file-name">{file_name}</div>
        <div class="file-path">{file_path}</div>
    </td>
    <td>{covered_lines}/{total_lines}</td>
    <td>
        <div class="coverage-cell">
            <span class="coverage-percent {coverage_class}">{coverage}%</span>
            <div class="mini-bar">
                <div class="mini-bar-fill {coverage_class}" style="width: {coverage}%"></div>
            </div>
        </div>
    </td>
</tr>
"""


def get_coverage_class(coverage):
    """Return CSS class based on coverage percentage."""
    if coverage >= 80:
        return 'good'
    elif coverage >= 50:
        return 'moderate'
    else:
        return 'low'


def generate_html_report(coverage_data, output_dir):
    """Generate HTML coverage report from Xcode coverage JSON."""
    
    # Collect all file data
    all_files = []
    total_covered_lines = 0
    total_executable_lines = 0
    
    targets = coverage_data.get('targets', [])
    
    for target in targets:
        target_name = target.get('name', 'Unknown')
        
        # Skip test targets and system frameworks
        if 'Tests' in target_name or target_name.startswith('__'):
            continue
            
        # Include all non-test targets (Swift packages)
        # This works for any package name
        
        files = target.get('files', [])
        
        for file_info in files:
            file_path = file_info.get('path', '')
            file_name = file_info.get('name', os.path.basename(file_path))
            
            # Skip non-Swift files
            if not file_name.endswith('.swift'):
                continue
            
            covered_lines = file_info.get('coveredLines', 0)
            executable_lines = file_info.get('executableLines', 0)
            line_coverage = file_info.get('lineCoverage', 0) * 100
            
            all_files.append({
                'name': file_name,
                'path': file_path,
                'covered_lines': covered_lines,
                'executable_lines': executable_lines,
                'coverage': round(line_coverage, 1)
            })
            
            total_covered_lines += covered_lines
            total_executable_lines += executable_lines
    
    # Sort files by coverage (lowest first to highlight areas needing work)
    all_files.sort(key=lambda x: x['coverage'])
    
    # Calculate total coverage
    total_coverage = (total_covered_lines / total_executable_lines * 100) if total_executable_lines > 0 else 0
    total_coverage = round(total_coverage, 1)
    
    # Generate file rows HTML
    file_rows = []
    for file_info in all_files:
        coverage_class = get_coverage_class(file_info['coverage'])
        row = FILE_ROW_TEMPLATE.format(
            file_name=file_info['name'],
            file_path=file_info['path'],
            covered_lines=file_info['covered_lines'],
            total_lines=file_info['executable_lines'],
            coverage=file_info['coverage'],
            coverage_class=coverage_class
        )
        file_rows.append(row)
    
    # Get commit info from environment
    commit_sha = os.environ.get('CI_COMMIT_SHORT_SHA', 'local')
    branch = os.environ.get('CI_COMMIT_REF_NAME', 'unknown')
    commit_info = f"Branch: {branch} • Commit: {commit_sha}"
    
    # Generate final HTML
    html = HTML_TEMPLATE.format(
        timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        total_coverage=total_coverage,
        coverage_class=get_coverage_class(total_coverage),
        covered_lines=total_covered_lines,
        total_lines=total_executable_lines,
        total_files=len(all_files),
        file_rows='\n'.join(file_rows),
        commit_info=commit_info
    )
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Write HTML file
    output_file = os.path.join(output_dir, 'index.html')
    with open(output_file, 'w') as f:
        f.write(html)
    
    print(f"✅ HTML coverage report generated: {output_file}")
    print(f"📊 Total Coverage: {total_coverage}% ({total_covered_lines}/{total_executable_lines} lines)")
    
    return total_coverage


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 generate-coverage-html.py <coverage.json> <output_dir>")
        print("       python3 generate-coverage-html.py - <output_dir>  # read from stdin")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_dir = sys.argv[2]
    
    # Read input
    if input_file == '-':
        coverage_json = sys.stdin.read()
    else:
        with open(input_file, 'r') as f:
            coverage_json = f.read()
    
    # Parse JSON
    try:
        coverage_data = json.loads(coverage_json)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Generate report
    generate_html_report(coverage_data, output_dir)


if __name__ == '__main__':
    main()

