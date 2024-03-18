! function(e, t) {
    "object" == typeof exports && "undefined" != typeof module ? t(exports, require("isomorphic-dompurify")) : "function" == typeof define && define.amd ? define(["exports", "isomorphic-dompurify"], t) : t((e = "undefined" != typeof globalThis ? globalThis : e || self).paydock = {})
}(this, function(e) {
    "use strict";

    function i(t, e) {
        var n = Object.keys(t);
        if (Object.getOwnPropertySymbols) {
            var i = Object.getOwnPropertySymbols(t);
            e && (i = i.filter(function(e) {
                return Object.getOwnPropertyDescriptor(t, e).enumerable
            })), n.push.apply(n, i)
        }
        return n
    }

    function y(t) {
        for (var e = 1; e < arguments.length; e++) {
            var n = null != arguments[e] ? arguments[e] : {};
            e % 2 ? i(Object(n), !0).forEach(function(e) {
                k(t, e, n[e])
            }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(t, Object.getOwnPropertyDescriptors(n)) : i(Object(n)).forEach(function(e) {
                Object.defineProperty(t, e, Object.getOwnPropertyDescriptor(n, e))
            })
        }
        return t
    }

    function x() {
        x = function() {
            return a
        };
        var d, a = {},
            e = Object.prototype,
            l = e.hasOwnProperty,
            h = Object.defineProperty || function(e, t, n) {
                e[t] = n.value
            },
            t = "function" == typeof Symbol ? Symbol : {},
            r = t.iterator || "@@iterator",
            n = t.asyncIterator || "@@asyncIterator",
            i = t.toStringTag || "@@toStringTag";

        function o(e, t, n) {
            return Object.defineProperty(e, t, {
                value: n,
                enumerable: !0,
                configurable: !0,
                writable: !0
            }), e[t]
        }
        try {
            o({}, "")
        } catch (d) {
            o = function(e, t, n) {
                return e[t] = n
            }
        }

        function s(e, t, n, i) {
            var o, a, s, u, r = t && t.prototype instanceof k ? t : k,
                c = Object.create(r.prototype),
                l = new R(i || []);
            return h(c, "_invoke", {
                value: (o = e, a = n, s = l, u = f, function(e, t) {
                    if (u === m) throw new Error("Generator is already running");
                    if (u === y) {
                        if ("throw" === e) throw t;
                        return {
                            value: d,
                            done: !0
                        }
                    }
                    for (s.method = e, s.arg = t;;) {
                        var n = s.delegate;
                        if (n) {
                            var i = T(n, s);
                            if (i) {
                                if (i === g) continue;
                                return i
                            }
                        }
                        if ("next" === s.method) s.sent = s._sent = s.arg;
                        else if ("throw" === s.method) {
                            if (u === f) throw u = y, s.arg;
                            s.dispatchException(s.arg)
                        } else "return" === s.method && s.abrupt("return", s.arg);
                        u = m;
                        var r = p(o, a, s);
                        if ("normal" === r.type) {
                            if (u = s.done ? y : v, r.arg === g) continue;
                            return {
                                value: r.arg,
                                done: s.done
                            }
                        }
                        "throw" === r.type && (u = y, s.method = "throw", s.arg = r.arg)
                    }
                })
            }), c
        }

        function p(e, t, n) {
            try {
                return {
                    type: "normal",
                    arg: e.call(t, n)
                }
            } catch (e) {
                return {
                    type: "throw",
                    arg: e
                }
            }
        }
        a.wrap = s;
        var f = "suspendedStart",
            v = "suspendedYield",
            m = "executing",
            y = "completed",
            g = {};

        function k() {}

        function u() {}

        function c() {}
        var E = {};
        o(E, r, function() {
            return this
        });
        var _ = Object.getPrototypeOf,
            w = _ && _(_(P([])));
        w && w !== e && l.call(w, r) && (E = w);
        var b = c.prototype = k.prototype = Object.create(E);

        function C(e) {
            ["next", "throw", "return"].forEach(function(t) {
                o(e, t, function(e) {
                    return this._invoke(t, e)
                })
            })
        }

        function S(u, c) {
            var t;
            h(this, "_invoke", {
                value: function(n, i) {
                    function e() {
                        return new c(function(e, t) {
                            ! function t(e, n, i, r) {
                                var o = p(u[e], u, n);
                                if ("throw" !== o.type) {
                                    var a = o.arg,
                                        s = a.value;
                                    return s && "object" == typeof s && l.call(s, "__await") ? c.resolve(s.__await).then(function(e) {
                                        t("next", e, i, r)
                                    }, function(e) {
                                        t("throw", e, i, r)
                                    }) : c.resolve(s).then(function(e) {
                                        a.value = e, i(a)
                                    }, function(e) {
                                        return t("throw", e, i, r)
                                    })
                                }
                                r(o.arg)
                            }(n, i, e, t)
                        })
                    }
                    return t = t ? t.then(e, e) : e()
                }
            })
        }

        function T(e, t) {
            var n = t.method,
                i = e.iterator[n];
            if (i === d) return t.delegate = null, "throw" === n && e.iterator.return && (t.method = "return", t.arg = d, T(e, t), "throw" === t.method) || "return" !== n && (t.method = "throw", t.arg = new TypeError("The iterator does not provide a '" + n + "' method")), g;
            var r = p(i, e.iterator, t.arg);
            if ("throw" === r.type) return t.method = "throw", t.arg = r.arg, t.delegate = null, g;
            var o = r.arg;
            return o ? o.done ? (t[e.resultName] = o.value, t.next = e.nextLoc, "return" !== t.method && (t.method = "next", t.arg = d), t.delegate = null, g) : o : (t.method = "throw", t.arg = new TypeError("iterator result is not an object"), t.delegate = null, g)
        }

        function O(e) {
            var t = {
                tryLoc: e[0]
            };
            1 in e && (t.catchLoc = e[1]), 2 in e && (t.finallyLoc = e[2], t.afterLoc = e[3]), this.tryEntries.push(t)
        }

        function A(e) {
            var t = e.completion || {};
            t.type = "normal", delete t.arg, e.completion = t
        }

        function R(e) {
            this.tryEntries = [{
                tryLoc: "root"
            }], e.forEach(O, this), this.reset(!0)
        }

        function P(t) {
            if (t || "" === t) {
                var e = t[r];
                if (e) return e.call(t);
                if ("function" == typeof t.next) return t;
                if (!isNaN(t.length)) {
                    var n = -1,
                        i = function e() {
                            for (; ++n < t.length;)
                                if (l.call(t, n)) return e.value = t[n], e.done = !1, e;
                            return e.value = d, e.done = !0, e
                        };
                    return i.next = i
                }
            }
            throw new TypeError(typeof t + " is not iterable")
        }
        return h(b, "constructor", {
            value: u.prototype = c,
            configurable: !0
        }), h(c, "constructor", {
            value: u,
            configurable: !0
        }), u.displayName = o(c, i, "GeneratorFunction"), a.isGeneratorFunction = function(e) {
            var t = "function" == typeof e && e.constructor;
            return !!t && (t === u || "GeneratorFunction" === (t.displayName || t.name))
        }, a.mark = function(e) {
            return Object.setPrototypeOf ? Object.setPrototypeOf(e, c) : (e.__proto__ = c, o(e, i, "GeneratorFunction")), e.prototype = Object.create(b), e
        }, a.awrap = function(e) {
            return {
                __await: e
            }
        }, C(S.prototype), o(S.prototype, n, function() {
            return this
        }), a.AsyncIterator = S, a.async = function(e, t, n, i, r) {
            void 0 === r && (r = Promise);
            var o = new S(s(e, t, n, i), r);
            return a.isGeneratorFunction(t) ? o : o.next().then(function(e) {
                return e.done ? e.value : o.next()
            })
        }, C(b), o(b, i, "Generator"), o(b, r, function() {
            return this
        }), o(b, "toString", function() {
            return "[object Generator]"
        }), a.keys = function(e) {
            var n = Object(e),
                i = [];
            for (var t in n) i.push(t);
            return i.reverse(),
                function e() {
                    for (; i.length;) {
                        var t = i.pop();
                        if (t in n) return e.value = t, e.done = !1, e
                    }
                    return e.done = !0, e
                }
        }, a.values = P, R.prototype = {
            constructor: R,
            reset: function(e) {
                if (this.prev = 0, this.next = 0, this.sent = this._sent = d, this.done = !1, this.delegate = null, this.method = "next", this.arg = d, this.tryEntries.forEach(A), !e)
                    for (var t in this) "t" === t.charAt(0) && l.call(this, t) && !isNaN(+t.slice(1)) && (this[t] = d)
            },
            stop: function() {
                this.done = !0;
                var e = this.tryEntries[0].completion;
                if ("throw" === e.type) throw e.arg;
                return this.rval
            },
            dispatchException: function(n) {
                if (this.done) throw n;
                var i = this;

                function e(e, t) {
                    return o.type = "throw", o.arg = n, i.next = e, t && (i.method = "next", i.arg = d), !!t
                }
                for (var t = this.tryEntries.length - 1; 0 <= t; --t) {
                    var r = this.tryEntries[t],
                        o = r.completion;
                    if ("root" === r.tryLoc) return e("end");
                    if (r.tryLoc <= this.prev) {
                        var a = l.call(r, "catchLoc"),
                            s = l.call(r, "finallyLoc");
                        if (a && s) {
                            if (this.prev < r.catchLoc) return e(r.catchLoc, !0);
                            if (this.prev < r.finallyLoc) return e(r.finallyLoc)
                        } else if (a) {
                            if (this.prev < r.catchLoc) return e(r.catchLoc, !0)
                        } else {
                            if (!s) throw new Error("try statement without catch or finally");
                            if (this.prev < r.finallyLoc) return e(r.finallyLoc)
                        }
                    }
                }
            },
            abrupt: function(e, t) {
                for (var n = this.tryEntries.length - 1; 0 <= n; --n) {
                    var i = this.tryEntries[n];
                    if (i.tryLoc <= this.prev && l.call(i, "finallyLoc") && this.prev < i.finallyLoc) {
                        var r = i;
                        break
                    }
                }
                r && ("break" === e || "continue" === e) && r.tryLoc <= t && t <= r.finallyLoc && (r = null);
                var o = r ? r.completion : {};
                return o.type = e, o.arg = t, r ? (this.method = "next", this.next = r.finallyLoc, g) : this.complete(o)
            },
            complete: function(e, t) {
                if ("throw" === e.type) throw e.arg;
                return "break" === e.type || "continue" === e.type ? this.next = e.arg : "return" === e.type ? (this.rval = this.arg = e.arg, this.method = "return", this.next = "end") : "normal" === e.type && t && (this.next = t), g
            },
            finish: function(e) {
                for (var t = this.tryEntries.length - 1; 0 <= t; --t) {
                    var n = this.tryEntries[t];
                    if (n.finallyLoc === e) return this.complete(n.completion, n.afterLoc), A(n), g
                }
            },
            catch: function(e) {
                for (var t = this.tryEntries.length - 1; 0 <= t; --t) {
                    var n = this.tryEntries[t];
                    if (n.tryLoc === e) {
                        var i = n.completion;
                        if ("throw" === i.type) {
                            var r = i.arg;
                            A(n)
                        }
                        return r
                    }
                }
                throw new Error("illegal catch attempt")
            },
            delegateYield: function(e, t, n) {
                return this.delegate = {
                    iterator: P(e),
                    resultName: t,
                    nextLoc: n
                }, "next" === this.method && (this.arg = d), g
            }
        }, a
    }

    function K(e) {
        return (K = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(e) {
            return typeof e
        } : function(e) {
            return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
        })(e)
    }

    function g(e, t) {
        if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
    }

    function r(e, t) {
        for (var n = 0; n < t.length; n++) {
            var i = t[n];
            i.enumerable = i.enumerable || !1, i.configurable = !0, "value" in i && (i.writable = !0), Object.defineProperty(e, v(i.key), i)
        }
    }

    function d(e, t, n) {
        return t && r(e.prototype, t), n && r(e, n), Object.defineProperty(e, "prototype", {
            writable: !1
        }), e
    }

    function k(e, t, n) {
        return (t = v(t)) in e ? Object.defineProperty(e, t, {
            value: n,
            enumerable: !0,
            configurable: !0,
            writable: !0
        }) : e[t] = n, e
    }

    function R() {
        return (R = Object.assign ? Object.assign.bind() : function(e) {
            for (var t = 1; t < arguments.length; t++) {
                var n = arguments[t];
                for (var i in n) Object.prototype.hasOwnProperty.call(n, i) && (e[i] = n[i])
            }
            return e
        }).apply(this, arguments)
    }

    function u(e, t) {
        if ("function" != typeof t && null !== t) throw new TypeError("Super expression must either be null or a function");
        e.prototype = Object.create(t && t.prototype, {
            constructor: {
                value: e,
                writable: !0,
                configurable: !0
            }
        }), Object.defineProperty(e, "prototype", {
            writable: !1
        }), t && n(e, t)
    }

    function c(e) {
        return (c = Object.setPrototypeOf ? Object.getPrototypeOf.bind() : function(e) {
            return e.__proto__ || Object.getPrototypeOf(e)
        })(e)
    }

    function n(e, t) {
        return (n = Object.setPrototypeOf ? Object.setPrototypeOf.bind() : function(e, t) {
            return e.__proto__ = t, e
        })(e, t)
    }

    function o(e) {
        if (void 0 === e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
        return e
    }

    function h(i) {
        var r = function() {
            if ("undefined" == typeof Reflect || !Reflect.construct) return !1;
            if (Reflect.construct.sham) return !1;
            if ("function" == typeof Proxy) return !0;
            try {
                return Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function() {})), !0
            } catch (e) {
                return !1
            }
        }();
        return function() {
            var e, t = c(i);
            if (r) {
                var n = c(this).constructor;
                e = Reflect.construct(t, arguments, n)
            } else e = t.apply(this, arguments);
            return function(e, t) {
                if (t && ("object" == typeof t || "function" == typeof t)) return t;
                if (void 0 !== t) throw new TypeError("Derived constructors may only return object or undefined");
                return o(e)
            }(this, e)
        }
    }

    function l() {
        return (l = "undefined" != typeof Reflect && Reflect.get ? Reflect.get.bind() : function(e, t, n) {
            var i = function(e, t) {
                for (; !Object.prototype.hasOwnProperty.call(e, t) && null !== (e = c(e)););
                return e
            }(e, t);
            if (i) {
                var r = Object.getOwnPropertyDescriptor(i, t);
                return r.get ? r.get.call(arguments.length < 3 ? e : n) : r.value
            }
        }).apply(this, arguments)
    }

    function a(e, t) {
        return function(e) {
            if (Array.isArray(e)) return e
        }(e) || function(e, t) {
            var n = null == e ? null : "undefined" != typeof Symbol && e[Symbol.iterator] || e["@@iterator"];
            if (null != n) {
                var i, r, o, a, s = [],
                    u = !0,
                    c = !1;
                try {
                    if (o = (n = n.call(e)).next, 0 === t) {
                        if (Object(n) !== n) return;
                        u = !1
                    } else
                        for (; !(u = (i = o.call(n)).done) && (s.push(i.value), s.length !== t); u = !0);
                } catch (e) {
                    c = !0, r = e
                } finally {
                    try {
                        if (!u && null != n.return && (a = n.return(), Object(a) !== a)) return
                    } finally {
                        if (c) throw r
                    }
                }
                return s
            }
        }(e, t) || p(e, t) || function() {
            throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")
        }()
    }

    function s(e) {
        return function(e) {
            if (Array.isArray(e)) return f(e)
        }(e) || function(e) {
            if ("undefined" != typeof Symbol && null != e[Symbol.iterator] || null != e["@@iterator"]) return Array.from(e)
        }(e) || p(e) || function() {
            throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")
        }()
    }

    function p(e, t) {
        if (e) {
            if ("string" == typeof e) return f(e, t);
            var n = Object.prototype.toString.call(e).slice(8, -1);
            return "Object" === n && e.constructor && (n = e.constructor.name), "Map" === n || "Set" === n ? Array.from(e) : "Arguments" === n || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n) ? f(e, t) : void 0
        }
    }

    function f(e, t) {
        (null == t || t > e.length) && (t = e.length);
        for (var n = 0, i = new Array(t); n < t; n++) i[n] = e[n];
        return i
    }

    function v(e) {
        var t = function(e, t) {
            if ("object" != typeof e || null === e) return e;
            var n = e[Symbol.toPrimitive];
            if (void 0 === n) return ("string" === t ? String : Number)(e);
            var i = n.call(e, t || "default");
            if ("object" != typeof i) return i;
            throw new TypeError("@@toPrimitive must return a primitive value.")
        }(e, "string");
        return "symbol" == typeof t ? t : String(t)
    }
    var m = "x-access-token",
        E = "x-user-public-key",
        _ = function() {
            function t() {
                g(this, t)
            }
            return d(t, null, [{
                key: "validateJWT",
                value: function(e) {
                    if (!e) return null;
                    var t = a(e.split("."), 3),
                        n = t[0],
                        i = t[1],
                        r = t[2];
                    if (!n || !i || !r) return null;
                    if (2 + n.length + i.length + r.length !== e.length) return null;
                    try {
                        return {
                            head: JSON.parse(atob(n)),
                            body: JSON.parse(atob(i)),
                            signature: r
                        }
                    } catch (e) {
                        return null
                    }
                }
            }, {
                key: "extractData",
                value: function(e) {
                    try {
                        return JSON.parse(atob(e.meta))
                    } catch (e) {
                        return null
                    }
                }
            }, {
                key: "extractMeta",
                value: function(e) {
                    try {
                        return JSON.parse(atob(e.meta)).meta
                    } catch (e) {
                        return null
                    }
                }
            }, {
                key: "getAccessHeaderNameByToken",
                value: function(e) {
                    return t.validateJWT(e) ? m : E
                }
            }]), t
        }(),
        w = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "version",
                get: function() {
                    return e._version.trim() || null
                }
            }]), e
        }();
    w.type = "client", w.headerKeys = Object.freeze({
        version: "x-sdk-version",
        type: "x-sdk-type"
    }), w._version = "v1.99.9-beta";
    var b, t, P, C, S = "sandbox",
        T = "sandbox-kovena",
        O = "sandbox-demo-kovena",
        A = "production",
        L = "staging",
        I = "staging_1",
        U = "staging_2",
        D = "staging_3",
        N = "staging_4",
        M = "staging_5",
        F = "staging_6",
        H = "staging_7",
        j = "staging_8",
        B = "staging_9",
        z = "staging_10",
        q = "staging_11",
        Y = "staging_12",
        V = "staging_13",
        W = "staging_14",
        G = "staging_15",
        J = "staging_cba",
        X = "preproduction_cba",
        Z = "production_cba",
        Q = [{
            env: S,
            url: "https://widget-sandbox."
        }, {
            env: T,
            url: "https://widget-sandbox."
        }, {
            env: "sandbox-demo",
            url: "https://widget-sandbox-demo."
        }, {
            env: O,
            url: "https://widget-sandbox-demo."
        }, {
            env: A,
            url: "https://widget."
        }, {
            env: L,
            url: "https://widsta."
        }, {
            env: I,
            url: "https://widsta-1."
        }, {
            env: U,
            url: "https://widsta-2."
        }, {
            env: D,
            url: "https://widsta-3."
        }, {
            env: N,
            url: "https://widsta-4."
        }, {
            env: M,
            url: "https://widsta-5."
        }, {
            env: F,
            url: "https://widsta-6."
        }, {
            env: H,
            url: "https://widsta-7."
        }, {
            env: j,
            url: "https://widsta-8."
        }, {
            env: B,
            url: "https://widsta-9."
        }, {
            env: z,
            url: "https://widsta-10."
        }, {
            env: q,
            url: "https://widsta-11."
        }, {
            env: Y,
            url: "https://widsta-12."
        }, {
            env: V,
            url: "https://widsta-13."
        }, {
            env: W,
            url: "https://widsta-14."
        }, {
            env: G,
            url: "https://widsta-15."
        }, {
            env: J,
            url: "https://widget.staging.powerboard."
        }, {
            env: X,
            url: "https://widget.preproduction.powerboard."
        }, {
            env: Z,
            url: "https://widget.powerboard."
        }],
        $ = [{
            env: S,
            url: "https://api-sandbox."
        }, {
            env: A,
            url: "https://api."
        }, {
            env: L,
            url: "https://apista."
        }, {
            env: I,
            url: "https://apista-1."
        }, {
            env: U,
            url: "https://apista-2."
        }, {
            env: D,
            url: "https://apista-3."
        }, {
            env: N,
            url: "https://apista-4."
        }, {
            env: M,
            url: "https://apista-5."
        }, {
            env: F,
            url: "https://apista-6."
        }, {
            env: H,
            url: "https://apista-7."
        }, {
            env: j,
            url: "https://apista-8."
        }, {
            env: B,
            url: "https://apista-9."
        }, {
            env: z,
            url: "https://apista-10."
        }, {
            env: q,
            url: "https://apista-11."
        }, {
            env: Y,
            url: "https://apista-12."
        }, {
            env: V,
            url: "https://apista-13."
        }, {
            env: W,
            url: "https://apista-14."
        }, {
            env: G,
            url: "https://apista-15."
        }, {
            env: J,
            url: "https://api.staging.powerboard."
        }, {
            env: X,
            url: "https://api.preproduction.powerboard."
        }, {
            env: Z,
            url: "https://api.powerboard."
        }],
        ee = [T, O],
        te = S,
        ne = "paydock.com",
        ie = "kovena.com",
        re = function() {
            function n(e) {
                var t = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : te;
                g(this, n), this.configs = e, this.setEnv(t)
            }
            return d(n, [{
                key: "setEnv",
                value: function(e, t) {
                    if (!this.isValidMode(this.configs, e)) throw new Error("unknown env: " + e);
                    if (this.env = e, t && !t.match("^([a-zA-Z0-9](?:(?:[a-zA-Z0-9-.]*(?!-)\\.(?![-.]))*[a-zA-Z0-9]+)?)$")) throw new Error("invalid: " + t);
                    t ? this.alias = t : -1 !== ee.indexOf(this.env) ? this.alias = ie : this.alias = ne
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.env
                }
            }, {
                key: "getConf",
                value: function() {
                    for (var e in this.configs)
                        if (this.configs.hasOwnProperty(e) && this.configs[e].env === this.getEnv()) return {
                            url: -1 !== this.configs[e].url.indexOf("localhost") ? this.configs[e].url : this.configs[e].url + this.alias,
                            env: this.configs[e].env
                        };
                    throw new Error("invalid env")
                }
            }, {
                key: "isValidMode",
                value: function(e, t) {
                    for (var n in e)
                        if (e.hasOwnProperty(n) && e[n].env === t) return !0;
                    return !1
                }
            }]), n
        }(),
        oe = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "extendSearchParams",
                value: function(e, t, n) {
                    return e.replace(new RegExp("([?&]" + t + "(?=[=&#]|$)[^#&]*|(?=#|$))"), "&" + t + "=" + encodeURIComponent(n)).replace(/^([^?&]+)&/, "$1?")
                }
            }, {
                key: "serialize",
                value: function(t) {
                    return Object.keys(t).map(function(e) {
                        return encodeURIComponent(e) + "=" + encodeURIComponent(t[e])
                    }).join("&")
                }
            }]), e
        }(),
        ae = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "generate",
                value: function() {
                    if ("undefined" == typeof window || void 0 === window.crypto || void 0 === window.crypto.getRandomValues) return this.random() + this.random() + "-" + this.random() + "-" + this.random() + "-" + this.random() + "-" + this.random() + this.random() + this.random();
                    var e = new Uint16Array(8);
                    return window.crypto.getRandomValues(e), this.hash(e[0]) + this.hash(e[1]) + "-" + this.hash(e[2]) + "-" + this.hash(e[3]) + "-" + this.hash(e[4]) + "-" + this.hash(e[5]) + this.hash(e[6]) + this.hash(e[7])
                }
            }, {
                key: "hash",
                value: function(e) {
                    for (var t = e.toString(16); t.length < 4;) t = "0" + t;
                    return t
                }
            }, {
                key: "random",
                value: function() {
                    return Math.floor(65536 * (1 + Math.random())).toString(16).substring(1)
                }
            }]), e
        }(),
        se = "/wallet/flypay",
        ue = function() {
            function t(e) {
                g(this, t), this.params = {}, this.widgetId = ae.generate(), this.linkResource = e, this.env = new re(Q), this.setParams({
                    widget_id: this.widgetId
                })
            }
            return d(t, [{
                key: "getNetUrl",
                value: function() {
                    return this.env.getConf().url + this.linkResource
                }
            }, {
                key: "getUrl",
                value: function() {
                    var e = this.getNetUrl(),
                        t = this.getParams();
                    for (var n in t) t.hasOwnProperty(n) && (e = oe.extendSearchParams(e, n, t[n]));
                    return e
                }
            }, {
                key: "setParams",
                value: function(e) {
                    this.params = R({}, this.params, e)
                }
            }, {
                key: "concatParams",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && e[t].length && ("string" != typeof this.params[t] && (this.params[t] = ""), this.params[t].length ? this.params[t] += "," + e[t] : this.params[t] += e[t])
                }
            }, {
                key: "getParams",
                value: function() {
                    return this.params
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.env.setEnv(e, t)
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.env.getEnv()
                }
            }, {
                key: "getBaseUrl",
                value: function() {
                    return this.env.getConf().url
                }
            }]), t
        }(),
        ce = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "values",
                value: function(t) {
                    return Object.keys(t).map(function(e) {
                        return t[e]
                    })
                }
            }]), e
        }(),
        le = {
            CARD: "card",
            BANK_ACCOUNT: "bank_account",
            CHECKOUT: "checkout"
        },
        de = {
            CARD_NAME: "card_name",
            CARD_NUMBER: "card_number",
            EXPIRE_MONTH: "expire_month",
            EXPIRE_YEAR: "expire_year",
            CARD_CCV: "card_ccv",
            CARD_PIN: "card_pin",
            ACCOUNT_NAME: "account_name",
            ACCOUNT_BSB: "account_bsb",
            ACCOUNT_NUMBER: "account_number",
            ACCOUNT_ROUTING: "account_routing",
            ACCOUNT_HOLDER_TYPE: "account_holder_type",
            ACCOUNT_BANK_NAME: "account_bank_name",
            ACCOUNT_TYPE: "account_type",
            FIRST_NAME: "first_name",
            LAST_NAME: "last_name",
            EMAIL: "email",
            PHONE: "phone",
            PHONE2: "phone2",
            ADDRESS_LINE1: "address_line1",
            ADDRESS_LINE2: "address_line2",
            ADDRESS_STATE: "address_state",
            ADDRESS_COUNTRY: "address_country",
            ADDRESS_CITY: "address_city",
            ADDRESS_POSTCODE: "address_postcode",
            ADDRESS_COMPANY: "address_company"
        },
        he = {
            BACKGROUND_COLOR: "background_color",
            BACKGROUND_ACTIVE_COLOR: "background_active_color",
            TEXT_COLOR: "text_color",
            BORDER_COLOR: "border_color",
            ICON_SIZE: "icon_size",
            BUTTON_COLOR: "button_color",
            ERROR_COLOR: "error_color",
            SUCCESS_COLOR: "success_color",
            FONT_SIZE: "font_size",
            FONT_FAMILY: "font_family"
        },
        pe = {
            TITLE: "title",
            TITLE_H1: "title_h1",
            TITLE_H2: "title_h2",
            TITLE_H3: "title_h3",
            TITLE_H4: "title_h4",
            TITLE_H5: "title_h5",
            TITLE_H6: "title_h6",
            FINISH: "finish_text",
            TITLE_DESCRIPTION: "title_description",
            SUBMIT_BUTTON: "submit_button",
            SUBMIT_BUTTON_PROCESSING: "submit_button_processing"
        },
        fe = {
            SUBMIT_BUTTON: "submit_button",
            TABS: "tabs"
        },
        ve = {
            AMEX: "amex",
            AUSBC: "ausbc",
            DINERS: "diners",
            DISCOVER: "discover",
            JAPCB: "japcb",
            LASER: "laser",
            MASTERCARD: "mastercard",
            SOLO: "solo",
            VISA: "visa",
            VISA_WHITE: "visa_white"
        },
        me = [].concat(["brand_name", "cart_border_color", "reference", "email", "hdr_img", "logo_img", "pay_flow_color", "first_name", "last_name", "address_line", "address_line2", "address_city", "address_state", "address_postcode", "address_country", "phone", "hide_shipping_address"], ["first_name", "last_name", "phone", "tokenize", "email", "gender", "date_of_birth", "charge", "statistics", "hide_shipping_address"], ["amount", "currency", "email", "first_name", "last_name", "address_line", "address_line2", "address_city", "address_state", "address_postcode", "address_country", "phone"], ["customer_storage_number", "tokenise_algorithm"]);
    (t = b = b || {}).STRIPE = "Stripe", t.FLYPAY = "Flypay", t.FLYPAY_V2 = "FlypayV2", t.PAYPAL = "Paypal", t.MASTERCARD = "MasterCard", t.AFTERPAY = "Afterpay", (C = P = P || {}).GOOGLE = "google", C.APPLE = "apple", C.FLYPAY = "flypay", C.FLYPAY_V2 = "flypayV2", C.PAYPAL = "paypal", C.AFTERPAY = "afterpay";
    var ye, ge, ke, Ee, _e = {
            CARD: "card",
            GIFT_CARD: "gift_card",
            BANK_ACCOUNT: "bank_account",
            CHECKOUT: "checkout"
        },
        we = {
            PAYMENT_SOURCE: "payment_source",
            CARD_PAYMENT_SOURCE_WITH_CVV: "card_payment_source_with_cvv",
            CARD_PAYMENT_SOURCE_WITHOUT_CVV: "card_payment_source_without_cvv"
        },
        be = function() {
            function l() {
                var e = 0 < arguments.length && void 0 !== arguments[0] ? arguments[0] : "default",
                    t = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : _e.CARD,
                    n = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : we.PAYMENT_SOURCE;
                if (g(this, l), -1 === ce.values(_e).indexOf(t)) throw new Error("unsupported payment type");
                if (t === _e.CHECKOUT) throw new Error('Payment type "checkout" is deprecated. Use CheckoutButton for this type of payments https://www.npmjs.com/package/@paydock/client-sdk#checkout-button');
                if (-1 === ce.values(we).indexOf(n)) throw new Error("unsupported purpose");
                this.env = new re($), this.configs = {
                    purpose: n,
                    meta: {},
                    dynamic_fields_position: !0,
                    predefined_fields: {
                        gateway_id: e,
                        type: t,
                        card_scheme: null,
                        card_processing_network: null
                    }
                }
            }
            return d(l, [{
                key: "setWebHookDestination",
                value: function(e) {
                    this.configs.webhook_destination = e
                }
            }, {
                key: "setSuccessRedirectUrl",
                value: function(e) {
                    this.configs.success_redirect_url = e
                }
            }, {
                key: "setErrorRedirectUrl",
                value: function(e) {
                    this.configs.error_redirect_url = e
                }
            }, {
                key: "setFormFields",
                value: function(e) {
                    for (var t in Array.isArray(this.configs.defined_form_fields) || (this.configs.defined_form_fields = []), e) e.hasOwnProperty(t) && (-1 !== ce.values(de).indexOf(e[t].replace("*", "")) ? this.configs.defined_form_fields.push(e[t]) : console.warn("Configuration::setFormFields: unsupported form field ".concat(e[t])))
                }
            }, {
                key: "setMeta",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && (-1 !== me.indexOf(t) ? this.configs.meta[t] = e[t] : console.warn("Configuration::setMeta: unsupported meta key ".concat(t)))
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.env.setEnv(e, t)
                }
            }, {
                key: "setLabel",
                value: function(e) {
                    this.configs.label = e
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.env.getEnv()
                }
            }, {
                key: "createToken",
                value: function(e, n, t) {
                    var i = 2 < arguments.length && void 0 !== t ? t : function(e) {};
                    this.send(e, function(e, t) {
                        if (200 <= t && t < 300) return n(e.resource.data.configuration_token);
                        void 0 === e.error || void 0 === e.error.message ? i("unknown error") : i(e.error.message)
                    })
                }
            }, {
                key: "send",
                value: function(e, t) {
                    var n = new XMLHttpRequest;
                    n.open("POST", this.getUrl(), !0), n.setRequestHeader("Content-Type", "application/json; charset=UTF-8"), n.setRequestHeader(_.getAccessHeaderNameByToken(e), e), w.version && (n.setRequestHeader(w.headerKeys.version, w.version), n.setRequestHeader(w.headerKeys.type, w.type)), n.send(JSON.stringify(this.getConfigs())), n.onload = function() {
                        var e = {};
                        try {
                            e = JSON.parse(n.responseText)
                        } catch (e) {}
                        t(e, n.status)
                    }
                }
            }, {
                key: "getConfigs",
                value: function() {
                    return this.configs
                }
            }, {
                key: "getUrl",
                value: function() {
                    return this.env.getConf().url + "/v1/remote-action/configs"
                }
            }, {
                key: "setGiftCardSchemeData",
                value: function(e, t) {
                    if (this.configs.predefined_fields.type !== _e.GIFT_CARD) throw new Error("unsupported payment type");
                    if (!e || !t) throw new Error("");
                    this.configs.predefined_fields.card_scheme = e, this.configs.predefined_fields.card_processing_network = t
                }
            }], [{
                key: "createEachToken",
                value: function(e, n, i, t) {
                    function r(t) {
                        n.hasOwnProperty(t) && n[t].createToken(e, function(e) {
                            a[t] = e, u++, n.length === u && l.finishCreatingEachToken(a, s, i, o)
                        }, function(e) {
                            s.push("gateway: ".concat(n[t].getConfigs().predefined_fields.gateway_id, " | ").concat(e)), u++, n.length === u && l.finishCreatingEachToken(a, s, i, o)
                        })
                    }
                    var o = 3 < arguments.length && void 0 !== t ? t : function(e) {},
                        a = new Array(n.length),
                        s = [],
                        u = 0;
                    for (var c in n) r(c)
                }
            }, {
                key: "finishCreatingEachToken",
                value: function(e, t, n, i) {
                    1 <= t.length ? i(t) : n(e)
                }
            }]), l
        }(),
        Ce = {
            INPUT: "input",
            SUBMIT_BUTTON: "submit_button",
            LABEL: "label",
            TITLE: "title",
            TITLE_DESCRIPTION: "title_description"
        },
        Se = {
            ERROR: "error",
            FOCUS: "focus",
            HOVER: "hover"
        },
        Te = [{
            element: Ce.INPUT,
            states: [Se.FOCUS, Se.ERROR],
            styles: ["color", "border", "border_radius", "background_color", "height", "text_decoration", "font_size", "font_family", "line_height", "font_weight", "padding", "margin", "transition"]
        }, {
            element: Ce.SUBMIT_BUTTON,
            states: [Se.HOVER],
            styles: ["color", "border", "border_radius", "background_color", "text_decoration", "font_size", "font_family", "line_height", "font_weight", "padding", "margin", "transition", "opacity"]
        }, {
            element: Ce.LABEL,
            states: [],
            styles: ["color", "text_decoration", "font_size", "font_family", "line_height", "font_weight", "padding", "margin"]
        }, {
            element: Ce.TITLE,
            states: [],
            styles: ["color", "text_decoration", "font_size", "font_family", "line_height", "font_weight", "padding", "margin", "text_align"]
        }, {
            element: Ce.TITLE_DESCRIPTION,
            states: [],
            styles: ["color", "text_decoration", "font_size", "font_family", "line_height", "font_weight", "padding", "margin", "text_align"]
        }],
        Oe = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "check",
                value: function(e, t, n, i) {
                    for (var r in e)
                        if (e.hasOwnProperty(r) && e[r].element === t) {
                            if (-1 === e[r].states.indexOf(n) && n) return !1;
                            for (var o in i)
                                if (i.hasOwnProperty(o) && -1 === e[r].styles.indexOf(o.replace("-", "_"))) return !1;
                            return !0
                        } return !1
                }
            }, {
                key: "encode",
                value: function(e, t, n) {
                    var i = [];
                    for (var r in n) n.hasOwnProperty(r) && i.push("".concat(r.replace("_", "-"), ":").concat(n[r]));
                    var o = i.join(";");
                    return t ? "".concat(e, "::").concat(t, "{").concat(o, "}") : "".concat(e, "{").concat(o, "}")
                }
            }, {
                key: "decode",
                value: function(e) {
                    var t = (e.match("::(.*){") || ["", null])[1],
                        n = null !== t ? (e.match("(.*)::") || ["", ""])[1].trim() : (e.match("(.*){") || ["", ""])[1].trim(),
                        i = (e.match("{(.*)}") || ["", ""])[1].split(";"),
                        r = {};
                    for (var o in i)
                        if (i.hasOwnProperty(o)) {
                            var a = i[o].split(":");
                            !a && 2 !== a.length || (r[a[0].trim()] = (a[1] || "").trim())
                        } return {
                        element: n,
                        state: t,
                        styles: r
                    }
                }
            }]), e
        }(),
        Ae = function() {
            function n(e, t) {
                if (g(this, n), this.configs = [], this.configTokens = [], this.link = new ue("/remote-action"), w.version && this.link.setParams({
                        sdk_version: w.version,
                        sdk_type: w.type
                    }), _.validateJWT(e) ? this.link.setParams({
                        token: e
                    }) : this.link.setParams({
                        public_key: e
                    }), this.accessToken = e, !t || Array.isArray(t) && !t.length) throw Error("configuration token is required");
                if ("string" == typeof t) this.configTokens.push(t);
                else if (t instanceof be) this.configs.push(t);
                else if (Array.isArray(t) && "string" == typeof t[0]) this.configTokens = t;
                else {
                    if (!(Array.isArray(t) && t[0] instanceof be)) throw Error("Unsupported type of configuration token");
                    this.configs = t
                }
            }
            return d(n, [{
                key: "setStyles",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setStyle(t, e[t])
                }
            }, {
                key: "usePhoneCountryMask",
                value: function(e) {
                    return e ? !e.only_countries || /^[a-z]+$/.test(e.only_countries.join("")) && 2 * e.only_countries.length === e.only_countries.join("").length ? !e.preferred_countries || /^[a-z]+$/.test(e.preferred_countries.join("")) && 2 * e.preferred_countries.length === e.preferred_countries.join("").length ? e.default_country && 2 !== e.default_country.length ? console.warn("Widget::usePhoneCountryMask[s: default_country - incorrect value length") : (this.link.setParams({
                        use_country_phone_mask: !0
                    }), e.only_countries && this.link.setParams({
                        phone_mask_only_countries: e.only_countries.join(",")
                    }), e.preferred_countries && this.link.setParams({
                        phone_mask_preferred_countries: e.preferred_countries.join(",")
                    }), void(e.default_country && this.link.setParams({
                        phone_mask_default_country: e.default_country
                    }))) : console.warn("Widget::usePhoneCountryMask[s: preferred_countries - unsupported symbols or incorrect length of value") : console.warn("Widget::usePhoneCountryMask[s: only_countries - unsupported symbols or incorrect length of value") : this.link.setParams({
                        use_country_phone_mask: !0
                    })
                }
            }, {
                key: "setStyle",
                value: function(e, t) {
                    -1 !== ce.values(he).indexOf(e) ? this.link.setParams(k({}, e, t)) : console.warn("Widget::setStyle[s: unsupported style param ".concat(e))
                }
            }, {
                key: "setTexts",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setText(t, e[t])
                }
            }, {
                key: "setText",
                value: function(e, t) {
                    -1 !== ce.values(pe).indexOf(e) ? this.link.setParams(k({}, e, t)) : console.warn("Widget::setText[s: unsupported text param ".concat(e))
                }
            }, {
                key: "setElementStyle",
                value: function(e, t, n) {
                    var i = 3 === arguments.length ? t : null,
                        r = 3 === arguments.length ? n : t;
                    if (!Oe.check(Te, e, i, r)) return console.warn('Styles for "'.concat(e, '" element with "').concat(i || "default", '" state was ignored because some of the arguments are unacceptable'));
                    this.link.concatParams({
                        element_styles: Oe.encode(e, i, r)
                    })
                }
            }, {
                key: "setFormValues",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setFormValue(t, e[t])
                }
            }, {
                key: "setFormValue",
                value: function(e, t) {
                    return -1 === ce.values(de).indexOf(e) ? console.warn("Widget::setFormValues[s: unsupported field ".concat(e)) : /\,/.test(t) || /\:/.test(t) ? console.warn("Widget::setFormValues[s: ".concat(e, " - unsupported symbols (: or ,) in value")) : void("string" == typeof this.link.getParams().form_values && this.link.getParams().form_values.length ? this.link.setParams({
                        form_values: "".concat(this.link.getParams().form_values, ",").concat(e, ":").concat(t)
                    }) : this.link.setParams({
                        form_values: "".concat(e, ":").concat(t)
                    }))
                }
            }, {
                key: "setFormLabels",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setFormLabel(t, e[t])
                }
            }, {
                key: "setFormLabel",
                value: function(e, t) {
                    if (-1 === ce.values(de).indexOf(e)) return console.warn("Widget::setFormLabel[s: unsupported field ".concat(e));
                    var n = null === t || "" === t ? " " : t;
                    if (/\,/.test(n) || /\:/.test(n)) return console.warn("Widget::setFormLabel[s: ".concat(e, " - unsupported symbols (: or ,) in value"));
                    this.link.concatParams({
                        form_labels: "".concat(e, ":").concat(n)
                    })
                }
            }, {
                key: "setFormPlaceholders",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setFormPlaceholder(t, e[t])
                }
            }, {
                key: "setFormPlaceholder",
                value: function(e, t) {
                    if (-1 === ce.values(de).indexOf(e)) return console.warn("Widget::setFormPlaceholder[s: unsupported field ".concat(e));
                    var n = null === t || "" === t ? " " : t;
                    if (/\,/.test(n) || /\:/.test(n)) return console.warn("Widget::setFormPlaceholder[s: ".concat(e, " - unsupported symbols (: or ,) in value"));
                    this.link.concatParams({
                        form_placeholders: "".concat(e, ":").concat(n)
                    })
                }
            }, {
                key: "setFormElements",
                value: function(e) {
                    var t = this;
                    e.forEach(function(e) {
                        return t.setFormElement(e)
                    })
                }
            }, {
                key: "setFormElement",
                value: function(e) {
                    e.value && this.setFormValue(e.field, e.value), e.label && this.setFormLabel(e.field, e.label), e.placeholder && this.setFormPlaceholder(e.field, e.placeholder)
                }
            }, {
                key: "setIcons",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setIcon(t, e[t])
                }
            }, {
                key: "setIcon",
                value: function(e, t) {
                    if (/\,/.test(t) || /\:/.test(t)) return console.warn("Widget::setIcon[s: ".concat(e, " - unsupported symbols (: or ,) in value"));
                    "string" == typeof this.link.getParams().icons && this.link.getParams().icons.length ? this.link.setParams({
                        icons: "".concat(this.link.getParams().icons, ",").concat(e, ":").concat(t)
                    }) : this.link.setParams({
                        icons: "".concat(e, ":").concat(t)
                    })
                }
            }, {
                key: "setHiddenElements",
                value: function(e) {
                    var t = [],
                        n = ce.values(fe).concat(ce.values(de));
                    for (var i in e) e.hasOwnProperty(i) && (-1 !== n.indexOf(e[i]) ? t.push(e[i]) : console.warn("Widget::setHiddenElements: unsupported element ".concat(e[i])));
                    t.length && this.link.concatParams({
                        hidden_elements: t.join(",")
                    })
                }
            }, {
                key: "setRefId",
                value: function(e) {
                    this.link.setParams({
                        ref_id: e
                    })
                }
            }, {
                key: "useGatewayFieldValidation",
                value: function() {
                    this.link.setParams({
                        fields_validation: !0
                    })
                }
            }, {
                key: "setSupportedCardIcons",
                value: function(e, t) {
                    var n = [];
                    for (var i in e) e.hasOwnProperty(i) && (-1 !== ce.values(ve).indexOf(e[i]) ? n.push(e[i]) : console.warn("Widget::cardTypes: unsupported type of cards ".concat(e[i])));
                    n.length && this.link.concatParams({
                        supported_card_types: n.join(",")
                    }), t && this.link.setParams({
                        validate_card_types: t
                    })
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    for (var n in this.link.setEnv(e, t), this.configs) this.configs.hasOwnProperty(n) && this.configs[n].setEnv(e, t)
                }
            }, {
                key: "getEnv",
                value: function() {
                    this.link.getEnv()
                }
            }, {
                key: "loadIFrameUrl",
                value: function(t, e) {
                    var n = this,
                        i = 1 < arguments.length && void 0 !== e ? e : function(e) {};
                    if (this.link.setParams({
                            configuration_tokens: ""
                        }), this.configTokens.length) return this.link.setParams({
                        configuration_tokens: this.configTokens.join(",")
                    }), t(this.link.getUrl());
                    be.createEachToken(this.accessToken, this.configs, function(e) {
                        return n.link.concatParams({
                            configuration_tokens: e.join(",")
                        }), t(n.link.getUrl())
                    }, function(e) {
                        i(e)
                    })
                }
            }, {
                key: "setLanguage",
                value: function(e) {
                    this.link.setParams({
                        language: e
                    })
                }
            }]), n
        }(),
        Re = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "insertToInput",
                value: function(e, t, n) {
                    if (void 0 !== n[t]) {
                        var i = document.querySelector(e);
                        i && (i.value = n[t])
                    }
                }
            }, {
                key: "subscribe",
                value: function(e, t, n) {
                    t.addEventListener ? t.addEventListener(e, n) : t.attachEvent("on".concat(e), n)
                }
            }]), e
        }(),
        Pe = function() {
            function t(e) {
                g(this, t), this.selector = e
            }
            return d(t, [{
                key: "isExist",
                value: function() {
                    return !!this.getElement()
                }
            }, {
                key: "getStyles",
                value: function(e) {
                    if (this.isExist()) {
                        var t = this.getElement().getAttribute("widget-style");
                        if (!t) return {};
                        var n = t.split(";");
                        return void 0 === n || n.length ? this.convertConfigs(n, e) : {}
                    }
                }
            }, {
                key: "on",
                value: function(e, t) {
                    this.isExist() && Re.subscribe(e, this.getElement(), t)
                }
            }, {
                key: "getAttr",
                value: function(e) {
                    if (this.isExist()) {
                        var t = this.getElement(),
                            n = [];
                        for (var i in e)
                            if (e.hasOwnProperty(i)) {
                                var r = e[i].replace(/_/g, "-"),
                                    o = t.getAttribute(r);
                                o && n.push("".concat(e[i], ":").concat(o))
                            } return void 0 === n || n.length ? this.convertConfigs(n, e) : {}
                    }
                }
            }, {
                key: "getElement",
                value: function() {
                    return document.querySelector(this.selector)
                }
            }, {
                key: "convertConfigs",
                value: function(e, t) {
                    var n = {};
                    for (var i in e)
                        if (e.hasOwnProperty(i)) {
                            var r = e[i].split(":"),
                                o = r[0].replace(/-/g, "_").trim(); - 1 !== t.indexOf(o) && (n[o] = r[1].trim())
                        } return n
                }
            }]), t
        }(),
        xe = function() {
            function t(e) {
                g(this, t), this.container = e
            }
            return d(t, [{
                key: "load",
                value: function(e, t) {
                    var n = 1 < arguments.length && void 0 !== t ? t : {};
                    if (this.container.isExist() && !this.isExist()) {
                        var i = document.createElement("iframe");
                        i.setAttribute("src", e), n.title && (i.title = n.title), this.container.getElement().appendChild(i)
                    }
                }
            }, {
                key: "loadFromHtml",
                value: function(e, t) {
                    var n = 1 < arguments.length && void 0 !== t ? t : {};
                    if (this.container.isExist() && !this.isExist()) {
                        var i = document.createElement("iframe");
                        i.setAttribute("height", "100%"), i.setAttribute("width", "100%"), n.title && (i.title = n.title);
                        this.container.getElement().appendChild(i);
                        var r = this.getElement().contentDocument;
                        r.open(), r.write("<html><head><style>html, body {margin: 0;} iframe {border: 0; width: 100%}</style><title></title></head><body>{{content}}</body></html>".replace("{{content}}", e)), r.close()
                    }
                }
            }, {
                key: "remove",
                value: function() {
                    if (this.container.isExist() && this.isExist()) {
                        var e = this.getElement();
                        this.container.getElement().removeChild(e)
                    }
                }
            }, {
                key: "show",
                value: function() {
                    this.isExist() && (this.setStyle("visibility", "visible"), this.setStyle("display", "block"))
                }
            }, {
                key: "hide",
                value: function(e) {
                    var t = 0 < arguments.length && void 0 !== e && e;
                    this.isExist() && (t ? this.setStyle("visibility", "hidden") : this.setStyle("display", "none"))
                }
            }, {
                key: "isExist",
                value: function() {
                    return !!this.getElement()
                }
            }, {
                key: "getElement",
                value: function() {
                    return this.container.isExist() ? this.container.getElement().querySelector("iframe") : null
                }
            }, {
                key: "setStyle",
                value: function(e, t) {
                    this.getElement().style[e] = t
                }
            }]), t
        }(),
        Le = {
            AFTER_LOAD: "afterLoad",
            SUBMIT: "submit",
            FINISH: "finish",
            VALIDATION_ERROR: "validationError",
            SYSTEM_ERROR: "systemError",
            CHECKOUT_SUCCESS: "checkoutSuccess",
            CHECKOUT_READY: "checkoutReady",
            CHECKOUT_ERROR: "checkoutError",
            CHECKOUT_COMPLETED: "checkoutCompleted",
            VALIDATION: "validation",
            SELECT: "select",
            UNSELECT: "unselect",
            NEXT: "next",
            PREV: "prev",
            META_CHANGE: "metaChange",
            RESIZE: "resize",
            CHARGE_AUTH_SUCCESS: "chargeAuthSuccess",
            CHARGE_AUTH_REJECT: "chargeAuthReject",
            CHARGE_AUTH_CANCELLED: "chargeAuthCancelled",
            ADDITIONAL_DATA_SUCCESS: "additionalDataCollectSuccess",
            ADDITIONAL_DATA_REJECT: "additionalDataCollectReject",
            CHARGE_AUTH: "chargeAuth",
            DISPATCH_SUCCESS: "dispatchSuccess",
            DISPATCH_ERROR: "dispatchError"
        },
        Ie = function() {
            function t(e) {
                var n = this;
                g(this, t), this.listeners = [], e && Re.subscribe("message", e, function(e) {
                    var t;
                    try {
                        t = JSON.parse(e.data)
                    } catch (e) {}
                    t && n.emit(t)
                })
            }
            return d(t, [{
                key: "emit",
                value: function(e) {
                    for (var t in this.listeners) this.listeners[t].event === e.event && e.widget_id === this.listeners[t].widget_id && this.listeners[t].listener.apply(this, [e])
                }
            }, {
                key: "on",
                value: function(e, t, n) {
                    for (var i in Le) Le.hasOwnProperty(i) && e === Le[i] && this.listeners.push({
                        event: e,
                        listener: n,
                        widget_id: t
                    })
                }
            }, {
                key: "clear",
                value: function() {
                    this.listeners = []
                }
            }, {
                key: "subscribe",
                value: function(e, t) {
                    e.addEventListener ? e.addEventListener("message", t) : e.attachEvent("onmessage", t)
                }
            }]), t
        }(),
        Ue = {
            SUBMIT_FORM: "submit_form",
            CHANGE_TAB: "tab",
            HIDE_ELEMENTS: "hide_elements",
            SHOW_ELEMENTS: "show_elements",
            REFRESH_CHECKOUT: "refresh_checkout",
            UPDATE_FORM_VALUES: "update_form_values",
            INIT_CHECKOUT: "init_checkout"
        },
        De = function() {
            function t(e) {
                g(this, t), this.iFrame = e
            }
            return d(t, [{
                key: "push",
                value: function(e, t) {
                    var n = 1 < arguments.length && void 0 !== t ? t : {};
                    if (this.iFrame.isExist()) {
                        -1 === ce.values(Ue).indexOf(e) && console.warn("unsupported trigger type");
                        var i = {
                            trigger: e,
                            destination: "widget.paydock",
                            data: n
                        };
                        this.iFrame.getElement().contentWindow.postMessage(JSON.stringify(i), "*")
                    }
                }
            }]), t
        }(),
        Ne = function() {
            function t(e) {
                g(this, t), this.intercepted = !1, this.selector = e
            }
            return d(t, [{
                key: "getElement",
                value: function() {
                    return document.querySelector(this.selector)
                }
            }, {
                key: "isExist",
                value: function() {
                    return !!this.getElement()
                }
            }, {
                key: "beforeSubmit",
                value: function(t) {
                    var n = this;
                    this.isExist() && this.subscribe(this.getElement(), function(e) {
                        e.preventDefault(), n.intercepted = !0, t.apply(n, [])
                    })
                }
            }, {
                key: "continueSubmit",
                value: function() {
                    var e = this;
                    this.isExist() && this.intercepted && (this.intercepted = !1, setTimeout(function() {
                        e.getElement().submit()
                    }, 50))
                }
            }, {
                key: "subscribe",
                value: function(e, t) {
                    e.addEventListener ? e.addEventListener("submit", t) : e.attachEvent("onsubmit", t)
                }
            }]), t
        }(),
        Me = function() {
            u(o, Ae);
            var r = h(o);

            function o(e, t, n) {
                var i;
                return g(this, o), (i = r.call(this, t, n)).validationData = {}, i.container = new Pe(e), i.iFrame = new xe(i.container), i.triggerElement = new De(i.iFrame), i.event = new Ie(window), i
            }
            return d(o, [{
                key: "load",
                value: function() {
                    var t = this;
                    this.setStyles(this.container.getStyles(ce.values(he))), this.setTexts(this.container.getAttr(ce.values(pe))), this.loadIFrameUrl(function(e) {
                        t.iFrame.load(e, {
                            title: "Card details"
                        }), t.afterLoad()
                    }, function(e) {
                        for (var t in console.error("Errors when creating a token[s, widget will not be load:"), e) e.hasOwnProperty(t) && console.error("--- | ".concat(e[t]))
                    })
                }
            }, {
                key: "afterLoad",
                value: function() {
                    var t = this;
                    this.on(Le.VALIDATION, function(e) {
                        t.validationData = e
                    })
                }
            }, {
                key: "on",
                value: function(e, t) {
                    var n = this;
                    return "function" == typeof t ? this.event.on(e, this.link.getParams().widget_id, t) : new Promise(function(t) {
                        return n.event.on(e, n.link.getParams().widget_id, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "trigger",
                value: function(e, t) {
                    var n = 1 < arguments.length && void 0 !== t ? t : {};
                    this.triggerElement.push(e, n)
                }
            }, {
                key: "getValidationState",
                value: function() {
                    return this.validationData
                }
            }, {
                key: "isValidForm",
                value: function() {
                    return !!this.validationData.form_valid
                }
            }, {
                key: "isInvalidField",
                value: function(e) {
                    var t = 0 < arguments.length && void 0 !== e ? e : "";
                    return !!this.validationData.invalid_fields && -1 !== this.validationData.invalid_fields.indexOf(t)
                }
            }, {
                key: "isFieldErrorShowed",
                value: function(e) {
                    var t = 0 < arguments.length && void 0 !== e ? e : "";
                    return !!this.validationData.invalid_showed_fields && -1 !== this.validationData.invalid_showed_fields.indexOf(t)
                }
            }, {
                key: "isInvalidFieldByValidator",
                value: function(e, t) {
                    var n = 0 < arguments.length && void 0 !== e ? e : "",
                        i = 1 < arguments.length ? t : void 0;
                    return !(this.validationData.validators && !this.validationData.validators[i]) && -1 !== this.validationData.validators[i].indexOf(n)
                }
            }, {
                key: "hide",
                value: function(e) {
                    this.iFrame.hide(e)
                }
            }, {
                key: "show",
                value: function() {
                    this.iFrame.show()
                }
            }, {
                key: "reload",
                value: function() {
                    this.iFrame.remove(), this.load()
                }
            }, {
                key: "hideElements",
                value: function(e) {
                    var t = [],
                        n = ce.values(fe).concat(ce.values(de));
                    for (var i in e) e.hasOwnProperty(i) && (-1 !== n.indexOf(e[i]) ? t.push(e[i]) : console.warn("Widget::hideElements: unsupported element ".concat(e[i])));
                    t.length && this.trigger(Ue.HIDE_ELEMENTS, {
                        elements: t.join(",")
                    })
                }
            }, {
                key: "showElements",
                value: function(e) {
                    var t = [],
                        n = ce.values(fe).concat(ce.values(de));
                    for (var i in e) e.hasOwnProperty(i) && (-1 !== n.indexOf(e[i]) ? t.push(e[i]) : console.warn("Widget::showElements: unsupported element ".concat(e[i])));
                    t.length && this.trigger(Ue.SHOW_ELEMENTS, {
                        elements: t.join(",")
                    })
                }
            }, {
                key: "updateFormValues",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.updateFormValue(t, e[t])
                }
            }, {
                key: "updateFormValue",
                value: function(e, t) {
                    return -1 === ce.values(de).indexOf(e) ? console.warn("Widget::setFormValues[s: unsupported field ".concat(e)) : /\,/.test(t) || /\:/.test(t) ? console.warn("Widget::setFormValues[s: ".concat(e, " - unsupported symbols (: or ,) in value")) : void this.trigger(Ue.UPDATE_FORM_VALUES, {
                        form_values: "".concat(e, ":").concat(t)
                    })
                }
            }, {
                key: "onFinishInsert",
                value: function(t, n) {
                    this.on(Le.FINISH, function(e) {
                        Re.insertToInput(t, n, e)
                    })
                }
            }, {
                key: "interceptSubmitForm",
                value: function(e) {
                    var t = this;
                    this.setHiddenElements([fe.SUBMIT_BUTTON]);
                    var n = new Ne(e);
                    n.beforeSubmit(function() {
                        t.triggerElement.push(Ue.SUBMIT_FORM, {}), t.event.on(Le.FINISH, t.link.getParams().widget_id, function() {
                            n.continueSubmit()
                        })
                    })
                }
            }, {
                key: "useCheckoutAutoSubmit",
                value: function() {
                    var t = this;
                    this.setHiddenElements([fe.SUBMIT_BUTTON]), this.on(Le.CHECKOUT_SUCCESS, function(e) {
                        t.trigger(Ue.SUBMIT_FORM)
                    }), this.on(Le.VALIDATION_ERROR, function(e) {
                        t.trigger(Ue.REFRESH_CHECKOUT)
                    }), this.on(Le.SYSTEM_ERROR, function(e) {
                        t.trigger(Ue.REFRESH_CHECKOUT)
                    })
                }
            }, {
                key: "useAutoResize",
                value: function() {
                    var t = this;
                    this.on(Le.RESIZE, function(e) {
                        t.iFrame.getElement() && (t.iFrame.getElement().scrolling = "no", e.height && t.iFrame.setStyle("height", e.height + "px"))
                    })
                }
            }]), o
        }(),
        Fe = function() {
            u(s, Me);
            var a = h(s);

            function s(e, t) {
                var n = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : "default",
                    i = 3 < arguments.length ? arguments[3] : void 0,
                    r = 4 < arguments.length ? arguments[4] : void 0;
                g(this, s);
                var o = new be(n, i, r);
                return a.call(this, e, t, o)
            }
            return d(s, [{
                key: "setWebHookDestination",
                value: function(e) {
                    this.configs[0].setWebHookDestination(e)
                }
            }, {
                key: "setSuccessRedirectUrl",
                value: function(e) {
                    this.configs[0].setSuccessRedirectUrl(e)
                }
            }, {
                key: "setErrorRedirectUrl",
                value: function(e) {
                    this.configs[0].setErrorRedirectUrl(e)
                }
            }, {
                key: "setFormFields",
                value: function(e) {
                    this.configs[0].setFormFields(e)
                }
            }, {
                key: "setFormElements",
                value: function(e) {
                    var t = this;
                    e.forEach(function(e) {
                        return t.setFormElement(e)
                    })
                }
            }, {
                key: "setFormElement",
                value: function(e) {
                    this.configs[0].setFormFields([e.field]), l(c(s.prototype), "setFormElement", this).call(this, R(R({}, e), {
                        field: e.field.replace("*", "")
                    }))
                }
            }, {
                key: "setMeta",
                value: function(e) {
                    this.configs[0].setMeta(e)
                }
            }, {
                key: "setGiftCardScheme",
                value: function(e, t) {
                    this.configs[0].setGiftCardSchemeData(e, t)
                }
            }]), s
        }(),
        He = {
            CLICK: "click",
            POPUP_REDIRECT: "popupRedirect",
            REDIRECT: "redirect",
            ERROR: "error",
            REFERRED: "referred",
            DECLINED: "declined",
            CANCELLED: "cancelled",
            ACCEPTED: "accepted",
            FINISH: "finish",
            CLOSE: "close"
        };
    (ge = ye = ye || {}).CONTEXTUAL = "contextual", ge.REDIRECT = "redirect", (Ee = ke = ke || {}).ZIPMONEY = "Zipmoney", Ee.PAYPAL = "PaypalClassic", Ee.AFTERPAY = "Afterpay";
    var je, Be, ze = "[Paydock:CheckoutButton]",
        qe = function() {
            function e() {
                g(this, e), this.env = new re($)
            }
            return d(e, [{
                key: "setEnv",
                value: function(e, t) {
                    this.env.setEnv(e, t)
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.env.getEnv()
                }
            }, {
                key: "getUrl",
                value: function() {
                    return this.env.getConf().url + this.getLink()
                }
            }, {
                key: "create",
                value: function(e, t, n, i) {
                    var r = this,
                        o = new XMLHttpRequest;
                    o.onload = function() {
                        r.parser(o.responseText, o.status, n, i)
                    }, o.open("POST", this.getUrl(), !0), o.setRequestHeader("Content-Type", "application/json; charset=UTF-8"), o.setRequestHeader(_.getAccessHeaderNameByToken(e), e), w.version && (o.setRequestHeader(w.headerKeys.version, w.version), o.setRequestHeader(w.headerKeys.type, w.type)), o.send(JSON.stringify(t))
                }
            }, {
                key: "get",
                value: function(e, t, n) {
                    var i = this,
                        r = new XMLHttpRequest;
                    r.onload = function() {
                        i.parser(r.responseText, r.status, t, n)
                    }, r.open("GET", this.getUrl(), !0), r.setRequestHeader("Content-Type", "application/json; charset=UTF-8"), r.setRequestHeader(_.getAccessHeaderNameByToken(e), e), w.version && (r.setRequestHeader(w.headerKeys.version, w.version), r.setRequestHeader(w.headerKeys.type, w.type)), r.send()
                }
            }, {
                key: "parser",
                value: function(e, t, n, i) {
                    var r = {};
                    try {
                        r = JSON.parse(e)
                    } catch (e) {}
                    if (200 <= t && t < 300 || 302 === t) return n(r.resource.data, t);
                    i(r.error || {
                        message: "unknown error"
                    }, t)
                }
            }]), e
        }(),
        Ye = function() {
            u(o, qe);
            var r = h(o);

            function o(e, t, n) {
                var i;
                return g(this, o), (i = r.call(this)).body = {
                    gateway_id: e,
                    meta: {},
                    success_redirect_url: t,
                    error_redirect_url: n,
                    redirect_url: t
                }, i
            }
            return d(o, [{
                key: "getLink",
                value: function() {
                    return "/v1/payment_sources/external_checkout"
                }
            }, {
                key: "setDescriptions",
                value: function(e) {
                    this.body.description = e
                }
            }, {
                key: "setMeta",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && (-1 !== me.indexOf(t) ? this.body.meta[t] = e[t] : console.warn("ExternalCheckout::setMeta: unsupported meta key ".concat(t)))
                }
            }, {
                key: "getConfigs",
                value: function() {
                    return this.body
                }
            }, {
                key: "send",
                value: function(e, n, t) {
                    var i = 2 < arguments.length && void 0 !== t ? t : function(e, t) {};
                    this.create(e, this.getConfigs(), function(e, t) {
                        n(e)
                    }, function(e, t) {
                        void 0 === e.message ? i("".concat(t, ": unknown error"), "unknown_error") : i(e.message, e.code)
                    })
                }
            }]), o
        }(),
        Ve = function() {
            u(i, qe);
            var n = h(i);

            function i(e) {
                var t;
                return g(this, i), (t = n.call(this)).token = e, t
            }
            return d(i, [{
                key: "getLink",
                value: function() {
                    return "/v1/payment_sources/external_checkout/:token".replace(":token", this.token)
                }
            }, {
                key: "send",
                value: function(e, n, t) {
                    var i = 2 < arguments.length && void 0 !== t ? t : function(e) {};
                    this.get(e, function(e, t) {
                        n(e)
                    }, function(e, t) {
                        void 0 === e.message ? i("".concat(t, ": unknown error")) : i(e.message)
                    })
                }
            }]), i
        }(),
        We = function() {
            function e() {
                g(this, e), this.events = {}
            }
            return d(e, [{
                key: "emit",
                value: function(e, t) {
                    var n = this.events[e];
                    n && n.forEach(function(e) {
                        e.call(null, t)
                    })
                }
            }, {
                key: "subscribe",
                value: function(e, t) {
                    var n = this;
                    return this.events[e] || (this.events[e] = []), this.events[e].push(t),
                        function() {
                            n.events[e] = n.events[e].filter(function(e) {
                                return t !== e
                            })
                        }
                }
            }]), e
        }(),
        Ke = '\n    <div class="cs-loader">\n      <div class="cs-loader-inner">\n        <label>\tâ—</label>\n        <label>\tâ—</label>\n        <label>\tâ—</label>\n        <label>\tâ—</label>\n        <label>\tâ—</label>\n        <label>\tâ—</label>\n      </div>\n    </div>\n',
        Ge = "\n    <style> \n        .cs-loader {\n          position: absolute;\n          top: 0;\n          left: 0;\n          height: 100%;\n          width: 100%;\n        }\n        \n        .cs-loader-inner {\n          transform: translateY(-50%);\n          top: 50%;\n          position: absolute;\n          width: calc(100% - 200px);\n          color: #8e8d8c;\n          padding: 0 100px;\n          text-align: center;\n        }\n        \n        \n        .cs-loader-inner label {\n          font-size: 20px;\n          opacity: 0;\n          display:inline-block;\n        }\n        \n        @keyframes lol {\n          0% {\n            opacity: 0;\n            transform: translateX(-300px);\n          }\n          33% {\n            opacity: 1;\n            transform: translateX(0px);\n          }\n          66% {\n            opacity: 1;\n            transform: translateX(0px);\n          }\n          100% {\n            opacity: 0;\n            transform: translateX(300px);\n          }\n        }\n        \n        @-webkit-keyframes lol {\n          0% {\n            opacity: 0;\n            -webkit-transform: translateX(-300px);\n          }\n          33% {\n            opacity: 1;\n            -webkit-transform: translateX(0px);\n          }\n          66% {\n            opacity: 1;\n            -webkit-transform: translateX(0px);\n          }\n          100% {\n            opacity: 0;\n            -webkit-transform: translateX(300px);\n            -moz-transform: translateX(300px);\n          }\n        }\n        \n        .cs-loader-inner label:nth-child(6) {\n          -webkit-animation: lol 3s infinite ease-in-out;\n          -moz-animation: lol 3s infinite ease-in-out;\n          animation: lol 3s infinite ease-in-out;\n        }\n        \n        .cs-loader-inner label:nth-child(5) {\n          -webkit-animation: lol 3s 100ms infinite ease-in-out;\n          -moz-animation: lol 3s 100ms infinite ease-in-out;\n          animation: lol 3s 100ms infinite ease-in-out;\n        }\n        \n        .cs-loader-inner label:nth-child(4) {\n          -webkit-animation: lol 3s 200ms infinite ease-in-out;\n          -moz-animation: lol 3s 200ms infinite ease-in-out;\n          animation: lol 3s 200ms infinite ease-in-out;\n        }\n        \n        .cs-loader-inner label:nth-child(3) {\n          -webkit-animation: lol 3s 300ms infinite ease-in-out;\n          -moz-animation: lol 3s 300ms infinite ease-in-out;\n          animation: lol 3s 300ms infinite ease-in-out;\n        }\n        \n        .cs-loader-inner label:nth-child(2) {\n          -webkit-animation: lol 3s 400ms infinite ease-in-out;\n          -moz-animation: lol 3s 400ms infinite ease-in-out;\n          animation: lol 3s 400ms infinite ease-in-out;\n        }\n        \n        .cs-loader-inner label:nth-child(1) {\n          -webkit-animation: lol 3s 500ms infinite ease-in-out;\n          -moz-animation: lol 3s 500ms infinite ease-in-out;\n          animation: lol 3s 500ms infinite ease-in-out;\n        }\n    </style>\n",
        Je = function() {
            function e() {
                g(this, e)
            }
            return d(e, null, [{
                key: "isFacebook",
                value: function() {
                    return -1 !== navigator.userAgent.indexOf("FBSN/iOS") && -1 !== navigator.userAgent.indexOf("AppleWebKit") && -1 !== navigator.userAgent.indexOf("(KHTML, like Gecko)")
                }
            }, {
                key: "isInstagram",
                value: function() {
                    return -1 !== navigator.userAgent.indexOf("iOS") && -1 !== navigator.userAgent.indexOf("Instagram") && -1 !== navigator.userAgent.indexOf("(KHTML, like Gecko)")
                }
            }, {
                key: "isSupportPopUp",
                value: function() {
                    return !this.isFacebook() && !this.isInstagram()
                }
            }, {
                key: "getLanguage",
                value: function() {
                    return window.navigator.language || ""
                }
            }, {
                key: "getTimezoneOffset",
                value: function() {
                    return (new Date).getTimezoneOffset()
                }
            }, {
                key: "getBrowserName",
                value: function() {
                    var e = navigator.userAgent;
                    return -1 < e.indexOf("Firefox") ? "Mozilla Firefox" : -1 < e.indexOf("Opera") ? "Opera" : -1 < e.indexOf("Trident") ? "Microsoft Internet Explorer" : -1 < e.indexOf("Edge") ? "Microsoft Edge" : -1 < e.indexOf("Chrome") ? "Google Chrome or Chromium" : -1 < e.indexOf("Safari") ? "Apple Safari" : "unknown"
                }
            }, {
                key: "isJavaEnabled",
                value: function() {
                    return navigator.javaEnabled()
                }
            }, {
                key: "getColorDepth",
                value: function() {
                    return screen.colorDepth
                }
            }, {
                key: "getScreenHeight",
                value: function() {
                    return screen.height
                }
            }, {
                key: "getScreenWidth",
                value: function() {
                    return screen.width
                }
            }, {
                key: "getBrowserInfo",
                value: function() {
                    var e, t = navigator.userAgent,
                        n = t.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
                    return /trident/i.test(n[1]) ? {
                        name: "IE",
                        version: (e = /\brv[ :]+(\d+)/g.exec(t) || [])[1] || ""
                    } : "Chrome" === n[1] && null != (e = t.match(/\bOPR|Edge\/(\d+)/)) ? {
                        name: "Opera",
                        version: e[1]
                    } : (n = n[2] ? [n[1], n[2]] : [navigator.appName, navigator.appVersion, "-?"], null != (e = t.match(/version\/(\d+)/i)) && n.splice(1, 1, e[1]), {
                        name: n[0],
                        version: n[1]
                    })
                }
            }]), e
        }(),
        Xe = "close",
        Ze = "focus",
        Qe = function() {
            function e() {
                g(this, e), this.description = "Don't see the secure checkout browser? We'll help you re-launch the window to complete your purchase", this.title = "Checkout", this.overlay = null, this.style = null, this.showControl = !0, this.showLoader = !0, this.eventEmitter = new We
            }
            return d(e, [{
                key: "initControl",
                value: function() {
                    if (!this.isInit() && this.showControl) {
                        if (!Je.isSupportPopUp()) return this.createLoader();
                        this.createTemplate(), this.createStyles(), this.eventHandler()
                    }
                }
            }, {
                key: "initLoader",
                value: function() {
                    !this.isInit() && this.showLoader && (this.createStyles(), this.createLoader())
                }
            }, {
                key: "eventHandler",
                value: function() {
                    var e = this,
                        t = document.querySelector("[data-close]"),
                        n = document.querySelector("[data-continue]");
                    t && Re.subscribe("click", t, function() {
                        return e.eventEmitter.emit(Xe, {})
                    }), n && Re.subscribe("click", n, function() {
                        return e.eventEmitter.emit(Ze, {})
                    })
                }
            }, {
                key: "clear",
                value: function() {
                    (this.style || this.overlay) && (this.style.parentNode.removeChild(this.style), this.overlay.parentNode.removeChild(this.overlay), this.style = null, this.overlay = null)
                }
            }, {
                key: "createLoader",
                value: function() {
                    var e = this,
                        t = document.body || document.getElementsByTagName("body")[0];
                    this.overlay = document.createElement("div"), this.overlay.classList.add("checkout-overlay"), this.overlay.setAttribute("checkout-overlay", " "), this.overlay.innerHTML = Ge + Ke, t.appendChild(this.overlay), setTimeout(function() {
                        e.isInit() && e.overlay.classList.add("display")
                    }, 5)
                }
            }, {
                key: "createTemplate",
                value: function() {
                    var e = this,
                        t = document.body || document.getElementsByTagName("body")[0],
                        n = String('\n    <div class="checkout-container">\n        <strong class="checkout-title" data-title>{{title}}</strong>\n        <p data-description>{{description}}</p>\n        <a href="#" data-continue>Continue</a>\n        <a href="#" data-close>Close</a>\n    </div>\n');
                    n = (n = n.replace("{{description}}", this.description)).replace("{{title}}", this.title), this.overlay = document.createElement("div"), this.overlay.classList.add("checkout-overlay"), this.overlay.setAttribute("checkout-overlay", " "), this.overlay.innerHTML = n, t.appendChild(this.overlay), setTimeout(function() {
                        e.isInit() && e.overlay.classList.add("display")
                    }, 5)
                }
            }, {
                key: "createStyles",
                value: function() {
                    var e = document.head || document.getElementsByTagName("head")[0],
                        t = String("\n    .hide-continue-button [data-continue] {\n        display: none;\n    }\n\n    .checkout-overlay .cs-loader-inner {\n         color: #ddd;\n    }\n\n    .checkout-overlay {\n        position: fixed;\n        top: 0;\n        left: 0;\n        right: 0;\n        bottom: 0;\n        background: rgba(0,0,0, 0.5);\n        text-align: center;\n        color: #fff;\n        opacity: 0;\n    }\n    .checkout-overlay.display {\n        opacity: 1;\n        transition: opacity 0.7s ease-out;\n    }\n    .checkout-overlay a { color: #00f; }\n    .checkout-container {\n        position: absolute;\n        top: 50%;\n        left: 0;\n        width: 100%;\n        margin-top: -{{width}}px;\n    }\n    .checkout-title {\n        font-size: 24px;\n        display: block;\n        text-transform: uppercase;\n    }\n    [data-close] {\n        position: fixed;\n        right: 32px;\n        top: 32px;\n        width: 32px;\n        height: 32px;\n        opacity: 0.3;\n        overflow: hidden;\n        text-indent: -9999px;\n    }\n    [data-close]:hover { opacity: 1; }\n    [data-close]:before, [data-close]:after {\n        position: absolute;\n        left: 15px;\n        content: ' ';\n        height: 33px;\n        width: 2px;\n        background-color: #00f;\n    }\n    [data-close]:before { transform: rotate(45deg); }\n    [data-close]:after { transform: rotate(-45deg); }\n"),
                        n = document.querySelector(".checkout-container");
                    t = t.replace("{{width}}", n ? String(n.offsetHeight / 2) : "0"), this.style = document.createElement("style"), this.style.type = "text/css", this.style.appendChild(document.createTextNode(t)), e.appendChild(this.style)
                }
            }, {
                key: "setBackdropDescription",
                value: function(e) {
                    this.description = e
                }
            }, {
                key: "setBackdropTitle",
                value: function(e) {
                    this.title = e
                }
            }, {
                key: "onTrigger",
                value: function(e, t) {
                    this.eventEmitter.subscribe(e, t)
                }
            }, {
                key: "isInit",
                value: function() {
                    return !(!this.overlay || !this.style)
                }
            }, {
                key: "hideContinueControl",
                value: function() {
                    this.isInit() && this.overlay.classList.add("hide-continue-button")
                }
            }, {
                key: "turnOffControl",
                value: function() {
                    this.showControl = !1
                }
            }, {
                key: "turnOffLoader",
                value: function() {
                    this.showLoader = !1
                }
            }]), e
        }(),
        $e = function() {
            function e() {
                g(this, e), this.widgetEnv = new re(Q)
            }
            return d(e, [{
                key: "error",
                value: function(e, t, n) {
                    n(!0)
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.widgetEnv.setEnv(e, t)
                }
            }]), e
        }();

    function et(e) {
        var t = 0 < arguments.length && void 0 !== e ? e : $e;
        return function() {
            u(o, t);
            var r = h(o);

            function o() {
                var e;
                g(this, o);
                for (var t = arguments.length, n = new Array(t), i = 0; i < t; i++) n[i] = arguments[i];
                return (e = r.call.apply(r, [this].concat(n))).background = new Qe, e.background.onTrigger(Ze, function() {
                    return e.continue()
                }), e.background.onTrigger(Xe, function() {
                    return e.stop()
                }), e
            }
            return d(o, [{
                key: "continue",
                value: function() {}
            }, {
                key: "stop",
                value: function() {}
            }, {
                key: "error",
                value: function(e, t, n) {
                    n(!0)
                }
            }, {
                key: "setSuspendedRedirectUri",
                value: function(e) {
                    this.suspendedRedirectUri = e
                }
            }, {
                key: "setBackgroundTitle",
                value: function(e) {
                    this.background.setBackdropTitle(e)
                }
            }, {
                key: "setBackgroundDescription",
                value: function(e) {
                    this.background.setBackdropDescription(e)
                }
            }, {
                key: "turnOffBackdrop",
                value: function() {
                    this.background.turnOffControl(), this.background.turnOffLoader()
                }
            }]), o
        }()
    }(Be = je = je || {}).SUCCESS = "success", Be.DECLINED = "declined", Be.CLOSE = "close", Be.REFERRED = "referred", Be.ERROR = "error";
    var tt = "paydock-dispatcher",
        nt = function() {
            function t(e) {
                g(this, t), this.messageSource = e, this.env = new re(Q)
            }
            return d(t, [{
                key: "restartDispatcher",
                value: function() {
                    var e = document.getElementById(tt);
                    e && e.parentNode && e.parentNode.removeChild(e);
                    var t = document.createElement("iframe");
                    t.setAttribute("src", this.env.getConf().url + "/dispatcher"), t.id = tt, t.style.display = "none", document.body.appendChild(t)
                }
            }, {
                key: "on",
                value: function(n, i) {
                    var r = this;
                    Re.subscribe("message", window, function(e) {
                        var t = null;
                        try {
                            t = JSON.parse(e.data)
                        } catch (e) {}
                        t && t.message_source === r.messageSource && t.event === n && i(t)
                    })
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.env.setEnv(e, t), this.restartDispatcher()
                }
            }]), t
        }(),
        it = function() {
            function e() {
                g(this, e), this.configs = {
                    width: 500,
                    height: 500,
                    scrollbars: !0,
                    resizable: !0,
                    top: 0,
                    left: 0
                }, this.eventEmitter = new We
            }
            return d(e, [{
                key: "isExist",
                value: function() {
                    return !(!this.getElement() || this.getElement().closed)
                }
            }, {
                key: "getElement",
                value: function() {
                    return this.window
                }
            }, {
                key: "init",
                value: function() {
                    var e = this;
                    if (!Je.isSupportPopUp()) return this.window = window;
                    var t = this.getConfigs();
                    this.window = window.open("about:blank", "_blank", "noopener=false,width=".concat(t.width, ",height=").concat(t.height, ",top=").concat(t.top, ",left=").concat(t.left, ",scrollbars=").concat(t.scrollbars ? "yes" : "no", ",resizable=").concat(t.resizable ? "yes" : "no")), this.showLoader();
                    var n = setInterval(function() {
                        e.isExist() || (clearInterval(n), e.eventEmitter.emit("close", {}))
                    }, 200)
                }
            }, {
                key: "redirect",
                value: function(e) {
                    this.isExist() && (this.window.location.href = e)
                }
            }, {
                key: "close",
                value: function() {
                    this.isExist() && this.getElement().close && (this.getElement().close(), this.window = null)
                }
            }, {
                key: "focus",
                value: function() {
                    this.isExist() && this.getElement().focus && this.getElement().focus()
                }
            }, {
                key: "setConfigs",
                value: function(e) {
                    this.configs = R(this.configs, e)
                }
            }, {
                key: "getNetConfigs",
                value: function() {
                    return R({}, this.configs)
                }
            }, {
                key: "getConfigs",
                value: function() {
                    var e = this.getNetConfigs();
                    return e.left = window.screenX + (window.screen.width / 2 - e.width / 2), e.top = window.screenY + (window.screen.height / 2 - e.height / 2), e
                }
            }, {
                key: "onClose",
                value: function(e) {
                    this.eventEmitter.subscribe("close", e)
                }
            }, {
                key: "initError",
                value: function(e) {
                    this.getElement().document.write("."), (this.getElement().document.body || this.getElement().document.getElementsByTagName("body")[0]).innerHTML = "<style>\n        .error-wrapper {\n            color: #ff0000;\n            display: flex;\n            justify-content: center;\n            align-items: center;\n            height: 100%;\n        }\n        </style>" + '<div class="error-wrapper"><div>{{error}}</div></div>'.replace("{{error}}", e)
                }
            }, {
                key: "showLoader",
                value: function() {
                    this.getElement().document.write(".");
                    var e = this.getElement().document.body || this.getElement().document.getElementsByTagName("body")[0];
                    if (e.innerHTML = Ge + Ke, this.env === L && this.env === I && this.env === U && this.env === D && this.env === N && this.env === M && this.env === F && this.env === H && this.env === j && this.env === B && this.env === z && this.env === q && this.env === Y && this.env === V && this.env === W && this.env === G) {
                        var t = 0;
                        Re.subscribe("click", e, function() {
                            5 === ++t && (e.innerHTML = '\n    <style>\n        html{width: 100%;height: 100%;}\n        body{margin: 0px;padding: 0px;background-color: #111;}\n        \n        .eye{\n          width: 20px; height: 8px;\n          background-color: #eee;\n          border-radius:0px 0px 20px 20px;\n          position: relative;\n          top: 40px;\n          left: 10px;\n          box-shadow:  40px 0px 0px 0px #eee;              \n        }\n        \n        .head{\n          -webkit-backface-visibility: hidden;\n          -moz-backface-visibility: hidden;\n          backface-visibility: hidden;          \n          position: relative;\n          margin: -250px auto;\n          width: 80px; height: 80px;\n          background-color: #111;\n          border-radius:50px;\n          box-shadow: inset -4px 2px 0px 0px #eee;\n           -webkit-animation:node 1.5s infinite alternate;\n          -webkit-animation-timing-function:ease-out;\n          -moz-animation:node 1.5s infinite alternate;\n          -moz-animation-timing-function:ease-out;\n          animation:node 1.5s infinite alternate;\n          animation-timing-function:ease-out;\n        }\n        .body{ \n          position: relative;\n          margin: 90px auto;\n          width: 140px; height: 120px;\n          background-color: #111;\n          border-radius: 50px/25px ;\n          box-shadow: inset -5px 2px 0px 0px #eee;\n          -webkit-animation:node2 1.5s infinite alternate;\n          -webkit-animation-timing-function:ease-out;  \n          -moz-animation:node2 1.5s infinite alternate;\n          -moz-animation-timing-function:ease-out;  \n          animation:node2 1.5s infinite alternate;\n          animation-timing-function:ease-out; \n        }\n        \n        @keyframes node {0%{ top:0px; }50%{ top:10px; }100% { top:0px;} }\n        @keyframes node2 {0%{ top:-5px; }50%{ top:10px; }100% { top:-5px;}}\n        @-moz-keyframes node {0%{ top:0px; }50%{ top:10px; }100% { top:0px;} }\n        @-moz-keyframes node2 {0%{ top:-5px; }50%{ top:10px; }100% { top:-5px;}}\n        @-webkit-keyframes node {0%{ top:0px; }50%{ top:10px; }100% { top:0px;} }\n        @-webkit-keyframes node2 {0%{ top:-5px; }50%{ top:10px; }100% { top:-5px;}}\n      \n               \n        .circ{\n          -webkit-backface-visibility: hidden;\n          -moz-backface-visibility: hidden;\n          backface-visibility: hidden;\n           margin: 60px auto;\n          width: 180px; height: 180px;\n          background-color: #111;\n          border-radius: 0px 0px 50px 50px;\n          position: relative;\n          z-index: -1;  \n          left: 0%;\n          top: 20%;\n          overflow: hidden;\n        }\n        \n        .hands{\n          -webkit-backface-visibility: hidden;\n          -moz-backface-visibility: hidden;\n          backface-visibility: hidden;\n          margin-top: 140px;\n          width: 120px;height: 120px;\n          position: absolute;\n          background-color: #111;\n          border-radius:20px;\n          box-shadow:-1px -4px 0px 0px #eee;\n          transform:rotate(45deg);\n          -webkit-transform:rotate(45deg);\n          -mox-transform:rotate(45deg);\n          top:75%;left: 16%;\n          z-index: 1;\n          -webkit-animation:node2 1.5s infinite alternate;\n          -webkit-animation-timing-function:ease-out;\n          -moz-animation:node2 1.5s infinite alternate;\n          -moz-animation-timing-function:ease-out;\n          animation:node2 1.5s infinite alternate;\n          animation-timing-function:ease-out;\n        }\n        \n        .load{  position: absolute;\n          width: 100px; height: 20px;\n           margin: -10px auto;\n           -webkit-font-smoothing: antialiased;\n          -moz-font-smoothing: antialiased;\n          font-smoothing: antialiased;\n          font-family: \'Julius Sans One\', sans-serif;\n          font-size:30px;\n          font-weight:400;\n          color:#eee;\n          left: 10%;\n          top: 5%;\n        }\n    </style>\n\n    <div class="circ">\n      <div class="load">A little patience ...</div>\n      <div class="hands"></div>\n      <div class="body"></div>\n      <div class="head">\n        <div class="eye"></div>\n      </div>\n    </div>\n')
                        })
                    }
                }
            }, {
                key: "setEnv",
                value: function(e) {
                    this.env = e
                }
            }]), e
        }(),
        rt = function() {
            u(i, et());
            var n = h(i);

            function i(e) {
                var t;
                return g(this, i), (t = n.call(this)).publicKey = e, t.checkout = null, t.dispatcher = new nt("checkout.paydock"), setTimeout(function() {
                    return t.dispatcher.restartDispatcher()
                }, 200), t.popup = new it, t
            }
            return d(i, [{
                key: "run",
                value: function() {
                    this.isRunning() || (this.popup.init(), this.background.initControl())
                }
            }, {
                key: "isRunning",
                value: function() {
                    return this.popup.isExist()
                }
            }, {
                key: "next",
                value: function(e) {
                    this.checkout = e, Je.isSupportPopUp() || window.localStorage.setItem("paydock_checkout_token", JSON.stringify(this.checkout)), this.popup.redirect(this.checkout.link)
                }
            }, {
                key: "continue",
                value: function() {
                    this.popup.focus()
                }
            }, {
                key: "stop",
                value: function() {
                    this.popup.close()
                }
            }, {
                key: "onStop",
                value: function(e) {
                    var t = this;
                    this.popup.onClose(function() {
                        t.background.clear(), t.checkout = null, e()
                    })
                }
            }, {
                key: "onCheckout",
                value: function(e, i) {
                    var r = this;
                    this.dispatcher.on(e, function(e) {
                        if (r.checkout && r.checkout.reference_id === e.reference_id) r.background.clear(), i(r.checkout);
                        else if (!Je.isSupportPopUp()) {
                            var t = window.localStorage.getItem("paydock_checkout_token");
                            if (!t) return;
                            var n = JSON.parse(t);
                            n && n.reference_id === e.reference_id && (window.localStorage.removeItem("paydock_checkout_token"), r.checkout = n, r.background.clear(), i(r.checkout))
                        }
                    })
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    l(c(i.prototype), "setEnv", this).call(this, e, t), this.dispatcher.setEnv(e, t), this.popup.setEnv(e)
                }
            }]), i
        }();

    function ot(e) {
        var n = 0 < arguments.length && void 0 !== e ? e : $e;
        return function() {
            u(t, n);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "setRedirectUrl",
                value: function(e) {
                    this.merchantRedirectUrl = e
                }
            }, {
                key: "getRedirectUrl",
                value: function() {
                    return this.merchantRedirectUrl
                }
            }, {
                key: "error",
                value: function(e, t, n) {
                    n(!1)
                }
            }]), t
        }()
    }

    function at(e) {
        return "run" in e
    }

    function st(e) {
        return "setRedirectUrl" in e
    }
    var ut = "undefined" != typeof globalThis ? globalThis : "undefined" != typeof window ? window : "undefined" != typeof global ? global : "undefined" != typeof self ? self : {};

    function ct() {
        throw new Error("Dynamic requires are not currently supported by rollup-plugin-commonjs")
    }

    function lt(e) {
        return e && e.__esModule && Object.prototype.hasOwnProperty.call(e, "default") ? e.default : e
    }

    function dt(e, t) {
        return e(t = {
            exports: {}
        }, t.exports), t.exports
    }
    lt(dt(function(e) {
        ! function r(o, a, s) {
            function u(t, e) {
                if (!a[t]) {
                    if (!o[t]) {
                        if (!e && ct) return ct();
                        if (c) return c(t, !0);
                        var n = new Error("Cannot find module '" + t + "'");
                        throw n.code = "MODULE_NOT_FOUND", n
                    }
                    var i = a[t] = {
                        exports: {}
                    };
                    o[t][0].call(i.exports, function(e) {
                        return u(o[t][1][e] || e)
                    }, i, i.exports, r, o, a, s)
                }
                return a[t].exports
            }
            for (var c = ct, e = 0; e < s.length; e++) u(s[e]);
            return u
        }({
            1: [function(e, t, n) {
                function i() {
                    throw new Error("setTimeout has not been defined")
                }

                function r() {
                    throw new Error("clearTimeout has not been defined")
                }

                function o(t) {
                    if (l === setTimeout) return setTimeout(t, 0);
                    if ((l === i || !l) && setTimeout) return l = setTimeout, setTimeout(t, 0);
                    try {
                        return l(t, 0)
                    } catch (e) {
                        try {
                            return l.call(null, t, 0)
                        } catch (e) {
                            return l.call(this, t, 0)
                        }
                    }
                }

                function a() {
                    v && p && (v = !1, p.length ? f = p.concat(f) : m = -1, f.length && s())
                }

                function s() {
                    if (!v) {
                        var e = o(a);
                        v = !0;
                        for (var t = f.length; t;) {
                            for (p = f, f = []; ++m < t;) p && p[m].run();
                            m = -1, t = f.length
                        }
                        p = null, v = !1,
                            function(t) {
                                if (d === clearTimeout) return clearTimeout(t);
                                if ((d === r || !d) && clearTimeout) return d = clearTimeout, clearTimeout(t);
                                try {
                                    d(t)
                                } catch (e) {
                                    try {
                                        return d.call(null, t)
                                    } catch (e) {
                                        return d.call(this, t)
                                    }
                                }
                            }(e)
                    }
                }

                function u(e, t) {
                    this.fun = e, this.array = t
                }

                function c() {}
                var l, d, h = t.exports = {};
                ! function() {
                    try {
                        l = "function" == typeof setTimeout ? setTimeout : i
                    } catch (e) {
                        l = i
                    }
                    try {
                        d = "function" == typeof clearTimeout ? clearTimeout : r
                    } catch (e) {
                        d = r
                    }
                }();
                var p, f = [],
                    v = !1,
                    m = -1;
                h.nextTick = function(e) {
                    var t = new Array(arguments.length - 1);
                    if (1 < arguments.length)
                        for (var n = 1; n < arguments.length; n++) t[n - 1] = arguments[n];
                    f.push(new u(e, t)), 1 !== f.length || v || o(s)
                }, u.prototype.run = function() {
                    this.fun.apply(null, this.array)
                }, h.title = "browser", h.browser = !0, h.env = {}, h.argv = [], h.version = "", h.versions = {}, h.on = c, h.addListener = c, h.once = c, h.off = c, h.removeListener = c, h.removeAllListeners = c, h.emit = c, h.prependListener = c, h.prependOnceListener = c, h.listeners = function(e) {
                    return []
                }, h.binding = function(e) {
                    throw new Error("process.binding is not supported")
                }, h.cwd = function() {
                    return "/"
                }, h.chdir = function(e) {
                    throw new Error("process.chdir is not supported")
                }, h.umask = function() {
                    return 0
                }
            }, {}],
            2: [function(e, i, r) {
                (function(W) {
                    ! function(e) {
                        if ("function" == typeof bootstrap) bootstrap("promise", e);
                        else if ("object" == K(r) && "object" == K(i)) i.exports = e();
                        else if ("undefined" != typeof ses) {
                            if (!ses.ok()) return;
                            ses.makeQ = e
                        } else {
                            if ("undefined" == typeof window && "undefined" == typeof self) throw new Error("This environment was not anticipated by Q. Please file a bug.");
                            var t = "undefined" != typeof window ? window : self,
                                n = t.Q;
                            t.Q = e(), t.Q.noConflict = function() {
                                return t.Q = n, this
                            }
                        }
                    }(function() {
                        function e(e) {
                            return function() {
                                return A.apply(e, arguments)
                            }
                        }

                        function s(e, t) {
                            if (w && t.stack && "object" == K(e) && null !== e && e.stack) {
                                for (var n = [], i = t; i; i = i.source) i.stack && (!e.__minimumStackCounter__ || e.__minimumStackCounter__ > i.stackCounter) && (U(e, "__minimumStackCounter__", {
                                    value: i.stackCounter,
                                    configurable: !0
                                }), n.unshift(i.stack));
                                n.unshift(e.stack);
                                var r = function(e) {
                                    for (var t = e.split("\n"), n = [], i = 0; i < t.length; ++i) {
                                        var r = t[i];
                                        a(r) || (-1 !== (o = r).indexOf("(module.js:") || -1 !== o.indexOf("(node.js:")) || !r || n.push(r)
                                    }
                                    var o;
                                    return n.join("\n")
                                }(n.join("\n" + F + "\n"));
                                U(e, "stack", {
                                    value: r,
                                    configurable: !0
                                })
                            }
                        }

                        function r(e) {
                            var t = /at .+ \((.+):(\d+):(?:\d+)\)$/.exec(e);
                            if (t) return [t[1], Number(t[2])];
                            var n = /at ([^ ]+):(\d+):(?:\d+)$/.exec(e);
                            if (n) return [n[1], Number(n[2])];
                            var i = /.*@(.+):(\d+)$/.exec(e);
                            return i ? [i[1], Number(i[2])] : void 0
                        }

                        function a(e) {
                            var t = r(e);
                            if (t) {
                                var n = t[0],
                                    i = t[1];
                                return n === C && T <= i && i <= V
                            }
                        }

                        function t() {
                            if (w) try {
                                throw new Error
                            } catch (e) {
                                var t = e.stack.split("\n"),
                                    n = r(0 < t[0].indexOf("@") ? t[1] : t[2]);
                                if (!n) return;
                                return C = n[0], n[1]
                            }
                        }

                        function u(e) {
                            return e instanceof l ? e : o(e) ? (t = e, n = c(), u.nextTick(function() {
                                try {
                                    t.then(n.resolve, n.reject, n.notify)
                                } catch (e) {
                                    n.reject(e)
                                }
                            }), n.promise) : m(e);
                            var t, n
                        }

                        function c() {
                            function t(n) {
                                r = n, u.longStackSupport && w && (i.source = n), P(o, function(e, t) {
                                    u.nextTick(function() {
                                        n.promiseDispatch.apply(n, t)
                                    })
                                }, void 0), a = o = void 0
                            }
                            var r, o = [],
                                a = [],
                                e = I(c.prototype),
                                i = I(l.prototype);
                            if (i.promiseDispatch = function(e, t, n) {
                                    var i = R(arguments);
                                    o ? (o.push(i), "when" === t && n[1] && a.push(n[1])) : u.nextTick(function() {
                                        r.promiseDispatch.apply(r, i)
                                    })
                                }, i.valueOf = function() {
                                    if (o) return i;
                                    var e = h(r);
                                    return p(e) && (r = e), e
                                }, i.inspect = function() {
                                    return r ? r.inspect() : {
                                        state: "pending"
                                    }
                                }, u.longStackSupport && w) try {
                                throw new Error
                            } catch (t) {
                                i.stack = t.stack.substring(t.stack.indexOf("\n") + 1), i.stackCounter = H++
                            }
                            return e.promise = i, e.resolve = function(e) {
                                r || t(u(e))
                            }, e.fulfill = function(e) {
                                r || t(m(e))
                            }, e.reject = function(e) {
                                r || t(v(e))
                            }, e.notify = function(n) {
                                r || P(a, function(e, t) {
                                    u.nextTick(function() {
                                        t(n)
                                    })
                                }, void 0)
                            }, e
                        }

                        function n(e) {
                            if ("function" != typeof e) throw new TypeError("resolver must be a function.");
                            var t = c();
                            try {
                                e(t.resolve, t.reject, t.notify)
                            } catch (e) {
                                t.reject(e)
                            }
                            return t.promise
                        }

                        function i(r) {
                            return n(function(e, t) {
                                for (var n = 0, i = r.length; n < i; n++) u(r[n]).then(e, t)
                            })
                        }

                        function l(r, o, t) {
                            void 0 === o && (o = function(e) {
                                return v(new Error("Promise does not support operation: " + e))
                            }), void 0 === t && (t = function() {
                                return {
                                    state: "unknown"
                                }
                            });
                            var a = I(l.prototype);
                            if (a.promiseDispatch = function(e, t, n) {
                                    var i;
                                    try {
                                        i = r[t] ? r[t].apply(a, n) : o.call(a, t, n)
                                    } catch (e) {
                                        i = v(e)
                                    }
                                    e && e(i)
                                }, a.inspect = t) {
                                var e = t();
                                "rejected" === e.state && (a.exception = e.reason), a.valueOf = function() {
                                    var e = t();
                                    return "pending" === e.state || "rejected" === e.state ? a : e.value
                                }
                            }
                            return a
                        }

                        function d(e, t, n, i) {
                            return u(e).then(t, n, i)
                        }

                        function h(e) {
                            if (p(e)) {
                                var t = e.inspect();
                                if ("fulfilled" === t.state) return t.value
                            }
                            return e
                        }

                        function p(e) {
                            return e instanceof l
                        }

                        function o(e) {
                            return (t = e) === Object(t) && "function" == typeof e.then;
                            var t
                        }

                        function f() {
                            B.length = 0, z.length = 0, Y = Y || !0
                        }

                        function v(t) {
                            var e, n, i = l({
                                when: function(e) {
                                    return e && function(t) {
                                        if (Y) {
                                            var n = x(z, t); - 1 !== n && ("object" == K(W) && "function" == typeof W.emit && u.nextTick.runAfter(function() {
                                                var e = x(q, t); - 1 !== e && (W.emit("rejectionHandled", B[n], t), q.splice(e, 1))
                                            }), z.splice(n, 1), B.splice(n, 1))
                                        }
                                    }(this), e ? e(t) : this
                                }
                            }, function() {
                                return this
                            }, function() {
                                return {
                                    state: "rejected",
                                    reason: t
                                }
                            });
                            return e = i, n = t, Y && ("object" == K(W) && "function" == typeof W.emit && u.nextTick.runAfter(function() {
                                -1 !== x(z, e) && (W.emit("unhandledRejection", n, e), q.push(e))
                            }), z.push(e), n && void 0 !== n.stack ? B.push(n.stack) : B.push("(no stack) " + n)), i
                        }

                        function m(n) {
                            return l({
                                when: function() {
                                    return n
                                },
                                get: function(e) {
                                    return n[e]
                                },
                                set: function(e, t) {
                                    n[e] = t
                                },
                                delete: function(e) {
                                    delete n[e]
                                },
                                post: function(e, t) {
                                    return null == e ? n.apply(void 0, t) : n[e].apply(n, t)
                                },
                                apply: function(e, t) {
                                    return n.apply(e, t)
                                },
                                keys: function() {
                                    return N(n)
                                }
                            }, void 0, function() {
                                return {
                                    state: "fulfilled",
                                    value: n
                                }
                            })
                        }

                        function y(e, t, n) {
                            return u(e).spread(t, n)
                        }

                        function g(e, t, n) {
                            return u(e).dispatch(t, n)
                        }

                        function k(e) {
                            return d(e, function(r) {
                                var o = 0,
                                    a = c();
                                return P(r, function(e, t, n) {
                                    var i;
                                    p(t) && "fulfilled" === (i = t.inspect()).state ? r[n] = i.value : (++o, d(t, function(e) {
                                        r[n] = e, 0 == --o && a.resolve(r)
                                    }, a.reject, function(e) {
                                        a.notify({
                                            index: n,
                                            value: e
                                        })
                                    }))
                                }, void 0), 0 === o && a.resolve(r), a.promise
                            })
                        }

                        function E(r) {
                            if (0 === r.length) return u.resolve();
                            var o = u.defer(),
                                a = 0;
                            return P(r, function(e, t, n) {
                                var i = r[n];
                                a++, d(i, function(e) {
                                    o.resolve(e)
                                }, function(e) {
                                    0 == --a && (e.message = "Q can't get fulfillment value from any promise, all promises were rejected. Last error message: " + e.message, o.reject(e))
                                }, function(e) {
                                    o.notify({
                                        index: n,
                                        value: e
                                    })
                                })
                            }, void 0), o.promise
                        }

                        function _(e) {
                            return d(e, function(e) {
                                return e = L(e, u), d(k(L(e, function(e) {
                                    return d(e, b, b)
                                })), function() {
                                    return e
                                })
                            })
                        }
                        var w = !1;
                        try {
                            throw new Error
                        } catch (e) {
                            w = !!e.stack
                        }

                        function b() {}
                        var C, S, T = t(),
                            O = function() {
                                function n() {
                                    for (var e, t; r.next;) e = (r = r.next).task, r.task = void 0, (t = r.domain) && (r.domain = void 0, t.enter()), i(e, t);
                                    for (; u.length;) i(e = u.pop());
                                    o = !1
                                }

                                function i(e, t) {
                                    try {
                                        e()
                                    } catch (e) {
                                        if (s) throw t && t.exit(), setTimeout(n, 0), t && t.enter(), e;
                                        setTimeout(function() {
                                            throw e
                                        }, 0)
                                    }
                                    t && t.exit()
                                }
                                var r = {
                                        task: void 0,
                                        next: null
                                    },
                                    t = r,
                                    o = !1,
                                    a = void 0,
                                    s = !1,
                                    u = [];
                                if (O = function(e) {
                                        t = t.next = {
                                            task: e,
                                            domain: s && W.domain,
                                            next: null
                                        }, o || (o = !0, a())
                                    }, "object" == K(W) && "[object process]" === W.toString() && W.nextTick) s = !0, a = function() {
                                    W.nextTick(n)
                                };
                                else if ("function" == typeof setImmediate) a = "undefined" != typeof window ? setImmediate.bind(window, n) : function() {
                                    setImmediate(n)
                                };
                                else if ("undefined" != typeof MessageChannel) {
                                    var e = new MessageChannel;
                                    e.port1.onmessage = function() {
                                        a = c, (e.port1.onmessage = n)()
                                    };
                                    var c = function() {
                                        e.port2.postMessage(0)
                                    };
                                    a = function() {
                                        setTimeout(n, 0), c()
                                    }
                                } else a = function() {
                                    setTimeout(n, 0)
                                };
                                return O.runAfter = function(e) {
                                    u.push(e), o || (o = !0, a())
                                }, O
                            }(),
                            A = Function.call,
                            R = e(Array.prototype.slice),
                            P = e(Array.prototype.reduce || function(e, t) {
                                var n = 0,
                                    i = this.length;
                                if (1 === arguments.length)
                                    for (;;) {
                                        if (n in this) {
                                            t = this[n++];
                                            break
                                        }
                                        if (++n >= i) throw new TypeError
                                    }
                                for (; n < i; n++) n in this && (t = e(t, this[n], n));
                                return t
                            }),
                            x = e(Array.prototype.indexOf || function(e) {
                                for (var t = 0; t < this.length; t++)
                                    if (this[t] === e) return t;
                                return -1
                            }),
                            L = e(Array.prototype.map || function(i, r) {
                                var o = this,
                                    a = [];
                                return P(o, function(e, t, n) {
                                    a.push(i.call(r, t, n, o))
                                }, void 0), a
                            }),
                            I = Object.create || function(e) {
                                function t() {}
                                return t.prototype = e, new t
                            },
                            U = Object.defineProperty || function(e, t, n) {
                                return e[t] = n.value, e
                            },
                            D = e(Object.prototype.hasOwnProperty),
                            N = Object.keys || function(e) {
                                var t = [];
                                for (var n in e) D(e, n) && t.push(n);
                                return t
                            },
                            M = e(Object.prototype.toString);
                        S = "undefined" != typeof ReturnValue ? ReturnValue : function(e) {
                            this.value = e
                        };
                        var F = "From previous event:";
                        (u.resolve = u).nextTick = O, u.longStackSupport = !1;
                        var H = 1;
                        "object" == K(W) && W && W.env && W.env.Q_DEBUG && (u.longStackSupport = !0), (u.defer = c).prototype.makeNodeResolver = function() {
                            var n = this;
                            return function(e, t) {
                                e ? n.reject(e) : 2 < arguments.length ? n.resolve(R(arguments, 1)) : n.resolve(t)
                            }
                        }, u.Promise = n, (u.promise = n).race = i, n.all = k, n.reject = v, (n.resolve = u).passByCopy = function(e) {
                            return e
                        }, l.prototype.passByCopy = function() {
                            return this
                        }, u.join = function(e, t) {
                            return u(e).join(t)
                        }, l.prototype.join = function(e) {
                            return u([this, e]).spread(function(e, t) {
                                if (e === t) return e;
                                throw new Error("Q can't join: not the same: " + e + " " + t)
                            })
                        }, u.race = i, l.prototype.race = function() {
                            return this.then(u.race)
                        }, (u.makePromise = l).prototype.toString = function() {
                            return "[object Promise]"
                        }, l.prototype.then = function(t, n, r) {
                            var i = this,
                                o = c(),
                                a = !1;
                            return u.nextTick(function() {
                                i.promiseDispatch(function(e) {
                                    a || (a = !0, o.resolve(function(e) {
                                        try {
                                            return "function" == typeof t ? t(e) : e
                                        } catch (e) {
                                            return v(e)
                                        }
                                    }(e)))
                                }, "when", [function(e) {
                                    a || (a = !0, o.resolve(function(e) {
                                        if ("function" == typeof n) {
                                            s(e, i);
                                            try {
                                                return n(e)
                                            } catch (e) {
                                                return v(e)
                                            }
                                        }
                                        return v(e)
                                    }(e)))
                                }])
                            }), i.promiseDispatch(void 0, "when", [void 0, function(e) {
                                var t, n, i = !1;
                                try {
                                    n = e, t = "function" == typeof r ? r(n) : n
                                } catch (e) {
                                    if (i = !0, !u.onerror) throw e;
                                    u.onerror(e)
                                }
                                i || o.notify(t)
                            }]), o.promise
                        }, u.tap = function(e, t) {
                            return u(e).tap(t)
                        }, l.prototype.tap = function(t) {
                            return t = u(t), this.then(function(e) {
                                return t.fcall(e).thenResolve(e)
                            })
                        }, u.when = d, l.prototype.thenResolve = function(e) {
                            return this.then(function() {
                                return e
                            })
                        }, u.thenResolve = function(e, t) {
                            return u(e).thenResolve(t)
                        }, l.prototype.thenReject = function(e) {
                            return this.then(function() {
                                throw e
                            })
                        }, u.thenReject = function(e, t) {
                            return u(e).thenReject(t)
                        }, u.nearer = h, u.isPromise = p, u.isPromiseAlike = o, u.isPending = function(e) {
                            return p(e) && "pending" === e.inspect().state
                        }, l.prototype.isPending = function() {
                            return "pending" === this.inspect().state
                        }, u.isFulfilled = function(e) {
                            return !p(e) || "fulfilled" === e.inspect().state
                        }, l.prototype.isFulfilled = function() {
                            return "fulfilled" === this.inspect().state
                        }, u.isRejected = function(e) {
                            return p(e) && "rejected" === e.inspect().state
                        }, l.prototype.isRejected = function() {
                            return "rejected" === this.inspect().state
                        };
                        var j, B = [],
                            z = [],
                            q = [],
                            Y = !0;
                        u.resetUnhandledRejections = f, u.getUnhandledReasons = function() {
                            return B.slice()
                        }, u.stopUnhandledRejectionTracking = function() {
                            f(), Y = !1
                        }, f(), u.reject = v, u.fulfill = m, u.master = function(n) {
                            return l({
                                isDef: function() {}
                            }, function(e, t) {
                                return g(n, e, t)
                            }, function() {
                                return u(n).inspect()
                            })
                        }, u.spread = y, l.prototype.spread = function(t, e) {
                            return this.all().then(function(e) {
                                return t.apply(void 0, e)
                            }, e)
                        }, u.async = function(t) {
                            return function() {
                                function e(e, t) {
                                    var n;
                                    if ("undefined" == typeof StopIteration) {
                                        try {
                                            n = i[e](t)
                                        } catch (e) {
                                            return v(e)
                                        }
                                        return n.done ? u(n.value) : d(n.value, r, o)
                                    }
                                    try {
                                        n = i[e](t)
                                    } catch (e) {
                                        return function(e) {
                                            return "[object StopIteration]" === M(e) || e instanceof S
                                        }(e) ? u(e.value) : v(e)
                                    }
                                    return d(n, r, o)
                                }
                                var i = t.apply(this, arguments),
                                    r = e.bind(e, "next"),
                                    o = e.bind(e, "throw");
                                return r()
                            }
                        }, u.spawn = function(e) {
                            u.done(u.async(e)())
                        }, u.return = function(e) {
                            throw new S(e)
                        }, u.promised = function(n) {
                            return function() {
                                return y([this, k(arguments)], function(e, t) {
                                    return n.apply(e, t)
                                })
                            }
                        }, u.dispatch = g, l.prototype.dispatch = function(e, t) {
                            var n = this,
                                i = c();
                            return u.nextTick(function() {
                                n.promiseDispatch(i.resolve, e, t)
                            }), i.promise
                        }, u.get = function(e, t) {
                            return u(e).dispatch("get", [t])
                        }, l.prototype.get = function(e) {
                            return this.dispatch("get", [e])
                        }, u.set = function(e, t, n) {
                            return u(e).dispatch("set", [t, n])
                        }, l.prototype.set = function(e, t) {
                            return this.dispatch("set", [e, t])
                        }, u.del = u.delete = function(e, t) {
                            return u(e).dispatch("delete", [t])
                        }, l.prototype.del = l.prototype.delete = function(e) {
                            return this.dispatch("delete", [e])
                        }, u.mapply = u.post = function(e, t, n) {
                            return u(e).dispatch("post", [t, n])
                        }, l.prototype.mapply = l.prototype.post = function(e, t) {
                            return this.dispatch("post", [e, t])
                        }, u.send = u.mcall = u.invoke = function(e, t) {
                            return u(e).dispatch("post", [t, R(arguments, 2)])
                        }, l.prototype.send = l.prototype.mcall = l.prototype.invoke = function(e) {
                            return this.dispatch("post", [e, R(arguments, 1)])
                        }, u.fapply = function(e, t) {
                            return u(e).dispatch("apply", [void 0, t])
                        }, l.prototype.fapply = function(e) {
                            return this.dispatch("apply", [void 0, e])
                        }, u.try = u.fcall = function(e) {
                            return u(e).dispatch("apply", [void 0, R(arguments, 1)])
                        }, l.prototype.fcall = function() {
                            return this.dispatch("apply", [void 0, R(arguments)])
                        }, u.fbind = function(e) {
                            var t = u(e),
                                n = R(arguments, 1);
                            return function() {
                                return t.dispatch("apply", [this, n.concat(R(arguments))])
                            }
                        }, l.prototype.fbind = function() {
                            var e = this,
                                t = R(arguments);
                            return function() {
                                return e.dispatch("apply", [this, t.concat(R(arguments))])
                            }
                        }, u.keys = function(e) {
                            return u(e).dispatch("keys", [])
                        }, l.prototype.keys = function() {
                            return this.dispatch("keys", [])
                        }, u.all = k, l.prototype.all = function() {
                            return k(this)
                        }, u.any = E, l.prototype.any = function() {
                            return E(this)
                        }, u.allResolved = (j = _, function() {
                            return "undefined" != typeof console && "function" == typeof console.warn && console.warn("allResolved is deprecated, use allSettled instead.", new Error("").stack), j.apply(j, arguments)
                        }), l.prototype.allResolved = function() {
                            return _(this)
                        }, u.allSettled = function(e) {
                            return u(e).allSettled()
                        }, l.prototype.allSettled = function() {
                            return this.then(function(e) {
                                return k(L(e, function(e) {
                                    function t() {
                                        return e.inspect()
                                    }
                                    return (e = u(e)).then(t, t)
                                }))
                            })
                        }, u.fail = u.catch = function(e, t) {
                            return u(e).then(void 0, t)
                        }, l.prototype.fail = l.prototype.catch = function(e) {
                            return this.then(void 0, e)
                        }, u.progress = function(e, t) {
                            return u(e).then(void 0, void 0, t)
                        }, l.prototype.progress = function(e) {
                            return this.then(void 0, void 0, e)
                        }, u.fin = u.finally = function(e, t) {
                            return u(e).finally(t)
                        }, l.prototype.fin = l.prototype.finally = function(t) {
                            if (!t || "function" != typeof t.apply) throw new Error("Q can't apply finally callback");
                            return t = u(t), this.then(function(e) {
                                return t.fcall().then(function() {
                                    return e
                                })
                            }, function(e) {
                                return t.fcall().then(function() {
                                    throw e
                                })
                            })
                        }, u.done = function(e, t, n, i) {
                            return u(e).done(t, n, i)
                        }, l.prototype.done = function(e, t, n) {
                            var i = function(e) {
                                    u.nextTick(function() {
                                        if (s(e, r), !u.onerror) throw e;
                                        u.onerror(e)
                                    })
                                },
                                r = e || t || n ? this.then(e, t, n) : this;
                            "object" == K(W) && W && W.domain && (i = W.domain.bind(i)), r.then(void 0, i)
                        }, u.timeout = function(e, t, n) {
                            return u(e).timeout(t, n)
                        }, l.prototype.timeout = function(e, t) {
                            var n = c(),
                                i = setTimeout(function() {
                                    t && "string" != typeof t || ((t = new Error(t || "Timed out after " + e + " ms")).code = "ETIMEDOUT"), n.reject(t)
                                }, e);
                            return this.then(function(e) {
                                clearTimeout(i), n.resolve(e)
                            }, function(e) {
                                clearTimeout(i), n.reject(e)
                            }, n.notify), n.promise
                        }, u.delay = function(e, t) {
                            return void 0 === t && (t = e, e = void 0), u(e).delay(t)
                        }, l.prototype.delay = function(n) {
                            return this.then(function(e) {
                                var t = c();
                                return setTimeout(function() {
                                    t.resolve(e)
                                }, n), t.promise
                            })
                        }, u.nfapply = function(e, t) {
                            return u(e).nfapply(t)
                        }, l.prototype.nfapply = function(e) {
                            var t = c(),
                                n = R(e);
                            return n.push(t.makeNodeResolver()), this.fapply(n).fail(t.reject), t.promise
                        }, u.nfcall = function(e) {
                            var t = R(arguments, 1);
                            return u(e).nfapply(t)
                        }, l.prototype.nfcall = function() {
                            var e = R(arguments),
                                t = c();
                            return e.push(t.makeNodeResolver()), this.fapply(e).fail(t.reject), t.promise
                        }, u.nfbind = u.denodeify = function(n) {
                            if (void 0 === n) throw new Error("Q can't wrap an undefined function");
                            var i = R(arguments, 1);
                            return function() {
                                var e = i.concat(R(arguments)),
                                    t = c();
                                return e.push(t.makeNodeResolver()), u(n).fapply(e).fail(t.reject), t.promise
                            }
                        }, l.prototype.nfbind = l.prototype.denodeify = function() {
                            var e = R(arguments);
                            return e.unshift(this), u.denodeify.apply(void 0, e)
                        }, u.nbind = function(n, i) {
                            var r = R(arguments, 2);
                            return function() {
                                var e = r.concat(R(arguments)),
                                    t = c();
                                return e.push(t.makeNodeResolver()), u(function() {
                                    return n.apply(i, arguments)
                                }).fapply(e).fail(t.reject), t.promise
                            }
                        }, l.prototype.nbind = function() {
                            var e = R(arguments, 0);
                            return e.unshift(this), u.nbind.apply(void 0, e)
                        }, u.nmapply = u.npost = function(e, t, n) {
                            return u(e).npost(t, n)
                        }, l.prototype.nmapply = l.prototype.npost = function(e, t) {
                            var n = R(t || []),
                                i = c();
                            return n.push(i.makeNodeResolver()), this.dispatch("post", [e, n]).fail(i.reject), i.promise
                        }, u.nsend = u.nmcall = u.ninvoke = function(e, t) {
                            var n = R(arguments, 2),
                                i = c();
                            return n.push(i.makeNodeResolver()), u(e).dispatch("post", [t, n]).fail(i.reject), i.promise
                        }, l.prototype.nsend = l.prototype.nmcall = l.prototype.ninvoke = function(e) {
                            var t = R(arguments, 1),
                                n = c();
                            return t.push(n.makeNodeResolver()), this.dispatch("post", [e, t]).fail(n.reject), n.promise
                        }, u.nodeify = function(e, t) {
                            return u(e).nodeify(t)
                        }, l.prototype.nodeify = function(t) {
                            if (!t) return this;
                            this.then(function(e) {
                                u.nextTick(function() {
                                    t(null, e)
                                })
                            }, function(e) {
                                u.nextTick(function() {
                                    t(e)
                                })
                            })
                        }, u.noConflict = function() {
                            throw new Error("Q.noConflict only works when Q is used as a global")
                        };
                        var V = t();
                        return u
                    })
                }).call(this, e("_process"))
            }, {
                _process: 1
            }],
            3: [function(e, t, n) {
                function o(e) {
                    switch (K(e)) {
                        case "string":
                            return e;
                        case "boolean":
                            return e ? "true" : "false";
                        case "number":
                            return isFinite(e) ? e : "";
                        default:
                            return ""
                    }
                }
                t.exports = function(n, i, r, e) {
                    return i = i || "&", r = r || "=", null === n && (n = void 0), "object" == K(n) ? Object.keys(n).map(function(e) {
                        var t = encodeURIComponent(o(e)) + r;
                        return Array.isArray(n[e]) ? n[e].map(function(e) {
                            return t + encodeURIComponent(o(e))
                        }).join(i) : t + encodeURIComponent(o(n[e]))
                    }).join(i) : e ? encodeURIComponent(o(e)) + r + encodeURIComponent(o(n)) : ""
                }
            }, {}],
            4: [function(e, t, n) {
                function i(e) {
                    return e && e.__esModule ? e : {
                        default: e
                    }
                }

                function r(n, i, r) {
                    return c.default.information("zip:checkout:init"), l.default.Promise(function(e, t) {
                        return n.onCheckout(e, t, {})
                    }).then(function(e) {
                        var t = e.redirect_uri || e.redirectUri || e.data && (e.data.redirect_uri || e.data.redirectUri);
                        if (!t) return c.default.debug("zip:checkout:error", "Response does not contain redirectUri property"), r(e), void n.onError({
                            code: "checkout_error",
                            message: "The response does not contain the redirectUri property",
                            detail: e
                        });
                        c.default.debug("zip:checkout:success", e), i({
                            redirectUri: t
                        })
                    }).catch(function(e) {
                        c.default.debug("zip:checkout:error", e), r(e), n.onError({
                            code: "checkout_error",
                            message: "Checkout response error",
                            detail: e
                        })
                    })
                }
                Object.defineProperty(n, "__esModule", {
                    value: !0
                }), n.Checkout = void 0;
                var o = function(e, t, n) {
                        return t && p(e.prototype, t), n && p(e, n), e
                    },
                    a = i(e("./modal")),
                    s = i(e("./options")),
                    u = i(e("./utility")),
                    c = i(e("./console")),
                    l = i((e("./events"), e("q"))),
                    d = (o(h, null, [{
                        key: "init",
                        value: function(t) {
                            if ("function" != typeof Object.assign && (Object.assign = function(e) {
                                    if (null == e) throw new TypeError("Cannot convert undefined or null to object");
                                    e = Object(e);
                                    for (var t = 1; t < arguments.length; t++) {
                                        var n = arguments[t];
                                        if (null != n)
                                            for (var i in n) Object.prototype.hasOwnProperty.call(n, i) && (e[i] = n[i])
                                    }
                                    return e
                                }), t = R({}, s.default, t), !this._validate(t)) return c.default.setLevel(t.logLevel), t.redirect ? r(t, function(e) {
                                return t.redirectFn(e.redirectUri)
                            }) : (e = t, (n = new a.default).onClose = e.onComplete.bind(e), n.build(), void r(e, function(e) {
                                return n.setUri(e.redirectUri)
                            }, function(e) {
                                return n.close(!1)
                            }));
                            var e, n
                        }
                    }, {
                        key: "attachButton",
                        value: function(e, t) {
                            var n = document.querySelectorAll(e);
                            if (!n.length) return config.onError({
                                code: "attach_error",
                                message: "Cannot find button to attach zipMoney checkout"
                            });
                            for (var i = 0; i < n.length; i++) u.default.addEventHandler(n[i], "click", function() {
                                return Zip.Checkout.init(t)
                            })
                        }
                    }, {
                        key: "_validate",
                        value: function(e) {
                            return ["error", "information", "debug"].indexOf(e.logLevel.toLowerCase()) < 0 && (e.logLevel = "error"), ["standard", "express"].indexOf(e.request.toLowerCase()) < 0 && (e.request = "standard"), e.onComplete = e.onComplete || function() {}, e.onError = e.onError || function() {}, e.checkoutUri || e.onCheckout !== s.default.onCheckout ? "express" === e.request ? e.onError({
                                code: "not_implemented",
                                message: "This feature is not yet implemented"
                            }) : e.redirect || e.onComplete !== s.default.onComplete || e.redirectUri ? void 0 : e.onError({
                                code: "validation",
                                message: "if onComplete function is not specified then redirectUri must be specified"
                            }) : e.onError({
                                code: "validation",
                                message: "if onCheckout function is not specified then checkoutUri must be specified"
                            })
                        }
                    }]), h);

                function h() {
                    ! function(e, t) {
                        if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
                    }(this, h)
                }

                function p(e, t) {
                    for (var n = 0; n < t.length; n++) {
                        var i = t[n];
                        i.enumerable = i.enumerable || !1, i.configurable = !0, "value" in i && (i.writable = !0), Object.defineProperty(e, i.key, i)
                    }
                }
                n.Checkout = d
            }, {
                "./console": 5,
                "./events": 6,
                "./modal": 8,
                "./options": 9,
                "./utility": 10,
                q: 2
            }],
            5: [function(e, t, n) {
                Object.defineProperty(n, "__esModule", {
                    value: !0
                });
                var i = "error",
                    r = {
                        error: function() {
                            var e;
                            (e = window.console).log.apply(e, arguments)
                        },
                        information: function() {
                            var e;
                            "error" !== i && (e = window.console).log.apply(e, arguments)
                        },
                        debug: function() {
                            var e;
                            "debug" === i && (e = window.console).log.apply(e, arguments)
                        },
                        setLevel: function(e) {
                            i = e
                        }
                    };
                n.default = r
            }, {}],
            6: [function(l, e, d) {
                (function(i) {
                    Object.defineProperty(d, "__esModule", {
                        value: !0
                    }), d.EventListener = void 0;
                    var e = function(e, t, n) {
                            return t && r(e.prototype, t), n && r(e, n), e
                        },
                        t = l("./utility");

                    function r(e, t) {
                        for (var n = 0; n < t.length; n++) {
                            var i = t[n];
                            i.enumerable = i.enumerable || !1, i.configurable = !0, "value" in i && (i.writable = !0), Object.defineProperty(e, i.key, i)
                        }
                    }
                    if ((t && t.__esModule ? t : {
                            default: t
                        }).default.isIe) {
                        var n = function(e, t) {
                            t = t || {
                                bubbles: !1,
                                cancelable: !1,
                                detail: void 0
                            };
                            var n = document.createEvent("CustomEvent");
                            return n.initCustomEvent(e, t.bubbles, t.cancelable, t.detail), n
                        };
                        n.prototype = i.Event.prototype, i.CustomEvent = n
                    }
                    var o = {},
                        a = d.EventListener = (e(s, null, [{
                            key: "constructor",
                            value: function() {
                                o = {}
                            }
                        }, {
                            key: "on",
                            value: function(e, t) {
                                o[e] = t
                            }
                        }, {
                            key: "off",
                            value: function(e) {
                                o[e] = null
                            }
                        }]), s);

                    function s() {
                        ! function(e, t) {
                            if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
                        }(this, s)
                    }
                    a.Event = function(e, t) {
                        this.eventType = e, this.data = t || {}
                    }, a.Event.eventTypes = {
                        resize: "resize",
                        transition: "transition",
                        close: "close",
                        complete: "complete",
                        clear: "clear"
                    };
                    var u = window.addEventListener ? "addEventListener" : "attachEvent",
                        c = window[u];
                    c("attachEvent" == u ? "onmessage" : "message", function(e) {
                        var t, n;
                        e.data.zipmoney && (t = e.data.msg, n = new i.CustomEvent("zipmoney", {
                            detail: t
                        }), i.dispatchEvent(n))
                    }, !1), c("zipmoney", function(e) {
                        var t, n = e.detail.eventType,
                            i = o[n];
                        i ? i(e.detail.data || {}) : (t = e, console.log("Unexpected Event", t))
                    }, !1)
                }).call(this, void 0 !== ut ? ut : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {})
            }, {
                "./utility": 10
            }],
            7: [function(i, e, t) {
                (function(e) {
                    var t = i("./checkout"),
                        n = i("./events");
                    e.Zip = e.Zip || {}, e.Zip.Checkout = t.Checkout, e.zipMoneyEvent = n.EventListener.ZipEvent
                }).call(this, void 0 !== ut ? ut : "undefined" != typeof self ? self : "undefined" != typeof window ? window : {})
            }, {
                "./checkout": 4,
                "./events": 6
            }],
            8: [function(e, t, n) {
                function i(e) {
                    return e && e.__esModule ? e : {
                        default: e
                    }
                }

                function o() {
                    return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
                }

                function s() {
                    var e = document.body,
                        t = document.documentElement;
                    return Math.max(e.scrollHeight, e.offsetHeight, t.clientHeight, t.scrollHeight, t.offsetHeight)
                }

                function u(e) {
                    for (var t = document.querySelectorAll("html, body"), n = 0; n < t.length; n++) t[n].style.overflowY = e
                }

                function c(e) {
                    var t = document.body.currentStyle || window.getComputedStyle(document.body),
                        n = e - (document.body.offsetHeight + (parseInt(t.marginTop, 10) + parseInt(t.marginBottom, 10)) - parseInt(t.height, 10));
                    document.body.style.height = n + "px"
                }
                Object.defineProperty(n, "__esModule", {
                    value: !0
                });
                var r = function(e, t, n) {
                        return t && m(e.prototype, t), n && m(e, n), e
                    },
                    a = i(e("./utility")),
                    l = e("./events"),
                    d = (i(e("./console")), {
                        iframeWidth: 400,
                        iframeMinWidth: 320,
                        iframeInitialHeight: 704,
                        iframeMinHeight: 600,
                        verticalMargin: 35
                    }),
                    h = ["resize", "transition", "close", "complete", "clear"],
                    p = "https://d3k1w8lx8mqizo.cloudfront.net/zm/",
                    f = (r(v, [{
                        key: "build",
                        value: function() {
                            this._initialHtmlHeight = s(), window.scrollTo(0, 0);
                            var e, t, n, i, r, o = this._frame = (e = this._frameUri, t = this._isMobile, (n = document.createElement("iframe")).id = "zipmoney-iframe", n.frameborder = 0, R(n.style, {
                                padding: "0",
                                border: "none",
                                zIndex: "999999",
                                backgroundColor: "#FFF",
                                backgroundImage: "url(" + p + "spinner.gif)",
                                backgroundRepeat: "no-repeat",
                                backgroundPosition: "50% 50%"
                            }), R(n.style, t ? {
                                overflow: "scroll",
                                width: "100%",
                                height: "100%",
                                position: "absolute",
                                top: "0",
                                bottom: "0",
                                left: "0",
                                right: "0",
                                margin: "0"
                            } : {
                                width: d.iframeWidth + "px",
                                minWidth: d.iframeMinWidth + "px",
                                height: d.iframeInitialHeight + "px",
                                margin: d.verticalMargin + "px auto 0 auto",
                                display: "table-row",
                                backgroundSize: "25%",
                                textAlign: "center",
                                boxShadow: "0px 0px 70px 0px rgb(0, 0, 0)"
                            }), n.src = e || "", n);
                            if (!this._isMobile) {
                                var a = ((r = document.createElement("img")).src = p + "icon-close.png", R(r.style, {
                                    width: "50px",
                                    height: "50px",
                                    position: "absolute",
                                    top: "20px",
                                    right: "20px",
                                    cursor: "pointer"
                                }), r);
                                a.onclick = this.close.bind(this), this._overlay = ((i = document.createElement("div")).className = "zipmoney-overlay", R(i.style, {
                                    position: "absolute",
                                    left: "0",
                                    top: "0",
                                    display: "table-cell",
                                    textAlign: "center",
                                    verticalAlign: "middle",
                                    background: "rgba(0, 0, 0, 0.75)",
                                    zIndex: "10000",
                                    height: "100%",
                                    width: "100%"
                                }), i), this._overlay.appendChild(a), this._overlay.appendChild(this._frame), this._overlay.appendChild(function() {
                                    var e = document.createElement("div");
                                    e.style.width = d.iframeWidth + "px", e.style.minWidth = d.iframeMinWidth + "px", e.style.margin = "10px auto 0 auto", e.style.overflow = "hidden";
                                    var t = document.createElement("img");
                                    t.src = p + "iframe-secure.png", t.style.cssFloat = "left";
                                    var n = document.createElement("img");
                                    return n.src = p + "poweredby-trans.png", n.style.cssFloat = "right", e.appendChild(t), e.appendChild(n), e
                                }()), o = this._overlay
                            }
                            document.body.appendChild(o), this._isMobile && c(this._frame.offsetHeight), u("auto"), this._startMonitoringWindowResize()
                        }
                    }, {
                        key: "setUri",
                        value: function(e) {
                            this._frameUri = e, this._frame && (this._frame.src = e)
                        }
                    }, {
                        key: "resize",
                        value: function(e) {
                            var t = this._isMobile ? 16 : 0,
                                n = (e = d.iframeMinHeight <= e ? e : d.iframeMinHeight, (e += t) + 2 * d.verticalMargin),
                                i = o();
                            this._frame.style.height = e + "px", this._overlay && (this._overlay.style.height = Math.max(i, this._initialHtmlHeight, n) + "px"), this._isMobile && c(e)
                        }
                    }, {
                        key: "transition",
                        value: function() {
                            window.scroll(0, 0)
                        }
                    }, {
                        key: "close",
                        value: function(e) {
                            var t = !(0 < arguments.length && void 0 !== e) || e,
                                n = {
                                    state: "cancelled"
                                };
                            this._events.length && (n = this._events.pop()), this._destroy(), this.onClose && t && this.onClose(n)
                        }
                    }, {
                        key: "complete",
                        value: function(e) {
                            this._events.push(e)
                        }
                    }, {
                        key: "clear",
                        value: function() {
                            this._events = []
                        }
                    }, {
                        key: "_startMonitoringWindowResize",
                        value: function() {
                            var r = this;
                            this._resizeHandler = a.default.debounce(function() {
                                return e = r, t = o(), n = s(), i = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth, e._overlay && (e._overlay.style.height = Math.max(t, n) + "px"), void(e._isMobile || i < d.iframeWidth ? e._frame.style.width = "100%" : e._frame.style.width = d.iframeWidth + "px");
                                var e, t, n, i
                            }, 250), a.default.addEventHandler(window, "resize", this._resizeHandler)
                        }
                    }, {
                        key: "_stopMonitoringWindowResize",
                        value: function() {
                            a.default.removeEventHandler(window, "resize", this._resizeHandler)
                        }
                    }, {
                        key: "_destroy",
                        value: function() {
                            this._stopMonitoringWindowResize(), this._overlay ? document.body.removeChild(this._overlay) : document.body.removeChild(this._frame), this._isMobile && (document.body.style.height = "initial"), u("initial"), this._overlay = this._frame = null, h.forEach(function(e) {
                                return l.EventListener.off(l.EventListener.Event.eventTypes[e])
                            })
                        }
                    }]), v);

                function v() {
                    var t = this;
                    (function(e, t) {
                        if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
                    })(this, v), this._events = [], this._isMobile = a.default.isMobileDevice(), h.forEach(function(e) {
                        return l.EventListener.on(l.EventListener.Event.eventTypes[e], t[e].bind(t))
                    })
                }

                function m(e, t) {
                    for (var n = 0; n < t.length; n++) {
                        var i = t[n];
                        i.enumerable = i.enumerable || !1, i.configurable = !0, "value" in i && (i.writable = !0), Object.defineProperty(e, i.key, i)
                    }
                }
                n.default = f
            }, {
                "./console": 5,
                "./events": 6,
                "./utility": 10
            }],
            9: [function(e, t, n) {
                function i(e) {
                    return e && e.__esModule ? e : {
                        default: e
                    }
                }
                Object.defineProperty(n, "__esModule", {
                    value: !0
                });
                var r = i(e("./xr")),
                    o = i(e("./console"));
                r.default.configure({
                    headers: {
                        "X-Requested-With": "XMLHttpRequest"
                    }
                });
                var a = {
                    request: "standard",
                    redirect: !1,
                    logLevel: "Error",
                    onCheckout: function(t, e) {
                        r.default.post(this.checkoutUri).then(function(e) {
                            return t(e.data)
                        }).catch(e)
                    },
                    onShippingAddressChanged: function(e, t) {
                        r.default.post(this.shippingUri).then(e).catch(t)
                    },
                    onComplete: function(e) {
                        if (o.default.information("zip:completed", e), "cancelled" !== e.state) {
                            var t = e.checkoutId ? "&checkoutId=" + e.checkoutId : "";
                            this.redirectFn(this.redirectUri + "?result=" + e.state + t)
                        }
                    },
                    onError: function(e) {
                        o.default.error(e)
                    },
                    redirectFn: function(e) {
                        window.location.href = e
                    }
                };
                n.default = a
            }, {
                "./console": 5,
                "./xr": 11
            }],
            10: [function(e, t, n) {
                Object.defineProperty(n, "__esModule", {
                    value: !0
                });
                var i = (function(e, t, n) {
                    return t && o(e.prototype, t), n && o(e, n), e
                }(r, null, [{
                    key: "isIe",
                    value: function() {
                        var e = -1,
                            t = window.navigator.userAgent,
                            n = t.indexOf("MSIE "),
                            i = t.indexOf("Trident/");
                        if (0 < n) e = parseInt(t.substring(n + 5, t.indexOf(".", n)), 10);
                        else if (0 < i) {
                            var r = t.indexOf("rv:");
                            e = parseInt(t.substring(r + 3, t.indexOf(".", r)), 10)
                        }
                        return -1 < e ? e : void 0
                    }
                }, {
                    key: "isMobileDevice",
                    value: function() {
                        var e = navigator.userAgent || navigator.vendor || window.opera;
                        return /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(e) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(e.substr(0, 4))
                    }
                }, {
                    key: "debounce",
                    value: function(i, r) {
                        var o;
                        return function() {
                            var e = this,
                                t = arguments,
                                n = !o;
                            clearTimeout(o), o = setTimeout(function() {
                                o = null, i.apply(e, t)
                            }, r), n && i.apply(e, t)
                        }
                    }
                }, {
                    key: "addEventHandler",
                    value: function(e, t, n) {
                        e.addEventListener ? e.addEventListener(t, n, !1) : e.attachEvent && e.attachEvent("on" + t, n)
                    }
                }, {
                    key: "removeEventHandler",
                    value: function(e, t, n) {
                        e.removeEventListener ? e.removeEventListener(t, n, !1) : e.detachEvent && e.detachEvent("on" + t, n)
                    }
                }]), r);

                function r() {
                    ! function(e, t) {
                        if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
                    }(this, r)
                }

                function o(e, t) {
                    for (var n = 0; n < t.length; n++) {
                        var i = t[n];
                        i.enumerable = i.enumerable || !1, i.configurable = !0, "value" in i && (i.writable = !0), Object.defineProperty(e, i.key, i)
                    }
                }
                n.default = i
            }, {}],
            11: [function(e, t, n) {
                function i(e) {
                    return e && e.__esModule ? e : {
                        default: e
                    }
                }

                function u(e, t) {
                    return {
                        status: e.status,
                        response: e.response,
                        data: t,
                        xhr: e
                    }
                }

                function c(e) {
                    for (var t = arguments.length, n = Array(1 < t ? t - 1 : 0), i = 1; i < t; i++) n[i - 1] = arguments[i];
                    for (var r in n)
                        if ({}.hasOwnProperty.call(n, r)) {
                            var o = n[r];
                            if ("object" === (void 0 === o ? "undefined" : l(o)))
                                for (var a in o) !{}.hasOwnProperty.call(o, a) || (e[a] = o[a])
                        } return e
                }

                function r(s) {
                    return t = function(t, n) {
                        var i = c({}, p, f, s),
                            r = i.xmlHttpRequest();
                        for (var e in i.abort && s.abort(function() {
                                n(u(r)), r.abort()
                            }), r.open(i.method, i.params ? i.url.split("?")[0] + "?" + (0, d.default)(i.params) : i.url, !0), r.withCredentials = i.withCredentials, r.addEventListener(h.LOAD, function() {
                                if (200 <= r.status && r.status < 300) {
                                    var e = null;
                                    r.responseText && (e = !0 === i.raw ? r.responseText : i.load(r.responseText)), t(u(r, e))
                                } else n(u(r))
                            }), r.addEventListener(h.ABORT, function() {
                                return n(u(r))
                            }), r.addEventListener(h.ERROR, function() {
                                return n(u(r))
                            }), r.addEventListener(h.TIMEOUT, function() {
                                return n(u(r))
                            }), i.headers) !{}.hasOwnProperty.call(i.headers, e) || r.setRequestHeader(e, i.headers[e]);
                        for (var o in i.events) !{}.hasOwnProperty.call(i.events, o) || r.addEventListener(o, i.events[o].bind(null, r), !1);
                        var a = "object" !== l(i.data) || i.raw ? i.data : i.dump(i.data);
                        void 0 !== a ? r.send(a) : r.send()
                    }, ((e = s) && e.promise ? e.promise : f.promise || p.promise)(t);
                    var e, t
                }
                Object.defineProperty(n, "__esModule", {
                    value: !0
                });
                var l = "function" == typeof Symbol && "symbol" == K(Symbol.iterator) ? function(e) {
                        return K(e)
                    } : function(e) {
                        return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : K(e)
                    },
                    d = i(e("querystring/encode")),
                    o = i(e("q")),
                    a = {
                        GET: "GET",
                        POST: "POST",
                        PUT: "PUT",
                        DELETE: "DELETE",
                        PATCH: "PATCH",
                        OPTIONS: "OPTIONS"
                    },
                    h = {
                        READY_STATE_CHANGE: "readystatechange",
                        LOAD_START: "loadstart",
                        PROGRESS: "progress",
                        ABORT: "abort",
                        ERROR: "error",
                        LOAD: "load",
                        TIMEOUT: "timeout",
                        LOAD_END: "loadend"
                    },
                    p = {
                        method: a.GET,
                        data: void 0,
                        headers: {
                            Accept: "application/json",
                            "Content-Type": "application/json"
                        },
                        dump: JSON.stringify,
                        load: JSON.parse,
                        xmlHttpRequest: function() {
                            return new XMLHttpRequest
                        },
                        promise: function(e) {
                            return o.default.Promise(e)
                        },
                        withCredentials: !1
                    },
                    f = {};
                r.assign = c, r.encode = d.default, r.configure = function(e) {
                    f = c({}, f, e)
                }, r.Methods = a, r.Events = h, r.defaults = p, r.get = function(e, t, n) {
                    return r(c({
                        url: e,
                        method: a.GET,
                        params: t
                    }, n))
                }, r.put = function(e, t, n) {
                    return r(c({
                        url: e,
                        method: a.PUT,
                        data: t
                    }, n))
                }, r.post = function(e, t, n) {
                    return r(c({
                        url: e,
                        method: a.POST,
                        data: t
                    }, n))
                }, r.patch = function(e, t, n) {
                    return r(c({
                        url: e,
                        method: a.PATCH,
                        data: t
                    }, n))
                }, r.del = function(e, t) {
                    return r(c({
                        url: e,
                        method: a.DELETE
                    }, t))
                }, r.options = function(e, t) {
                    return r(c({
                        url: e,
                        method: a.OPTIONS
                    }, t))
                }, n.default = r
            }, {
                q: 2,
                "querystring/encode": 3
            }]
        }, {}, [7])
    }));
    var ht, pt = function() {
            u(n, $e);
            var t = h(n);

            function n() {
                var e;
                return g(this, n), (e = t.call(this)).apiEnv = new re($), e
            }
            return d(n, [{
                key: "setEnv",
                value: function(e, t) {
                    l(c(n.prototype), "setEnv", this).call(this, e, t), this.apiEnv.setEnv(e, t)
                }
            }, {
                key: "getCheckoutUri",
                value: function(e) {
                    return this.apiEnv.getConf().url + "/v1/echo?" + oe.serialize({
                        json_body: JSON.stringify({
                            redirect_uri: e
                        })
                    })
                }
            }]), n
        }(),
        ft = function() {
            u(n, et(pt));
            var t = h(n);

            function n() {
                var e;
                return g(this, n), (e = t.call(this)).runs = !1, e.eventEmitter = new We, e
            }
            return d(n, [{
                key: "run",
                value: function() {
                    this.runs = !0, this.background.initLoader()
                }
            }, {
                key: "isRunning",
                value: function() {
                    return this.runs
                }
            }, {
                key: "next",
                value: function(e) {
                    var t = this;
                    this.background.clear(), this.checkout = e;
                    var n = this.getCheckoutUri(this.checkout.link);
                    Zip.Checkout.init({
                        checkoutUri: n,
                        onComplete: function(e) {
                            return t.eventHandler(e)
                        },
                        onError: function(e) {
                            return t.eventHandler(e)
                        }
                    })
                }
            }, {
                key: "getSuccessRedirectUri",
                value: function() {
                    return this.suspendedRedirectUri ? this.suspendedRedirectUri : this.widgetEnv.getConf().url + String("/checkout/zipmoney/suspended")
                }
            }, {
                key: "getErrorRedirectUri",
                value: function() {
                    return this.getSuccessRedirectUri()
                }
            }, {
                key: "stop",
                value: function() {
                    l(c(n.prototype), "stop", this).call(this), this.runs = !1;
                    var e = document.querySelector(".zipmoney-overlay");
                    e && e.remove(), this.eventEmitter.emit(je.CLOSE)
                }
            }, {
                key: "onStop",
                value: function(e) {
                    var t = this;
                    this.eventEmitter.subscribe(je.CLOSE, function() {
                        t.background.clear(), e()
                    })
                }
            }, {
                key: "onCheckout",
                value: function(e, t) {
                    var n = this;
                    this.eventEmitter.subscribe(e, function() {
                        t(n.checkout)
                    })
                }
            }, {
                key: "eventHandler",
                value: function(e) {
                    switch (this.runs = !1, e.state) {
                        case "approved":
                            this.eventEmitter.emit(je.CLOSE), this.eventEmitter.emit(je.SUCCESS);
                            break;
                        case "declined":
                            this.eventEmitter.emit(je.CLOSE), this.eventEmitter.emit(je.DECLINED);
                            break;
                        case "cancelled":
                            this.eventEmitter.emit(je.CLOSE);
                            break;
                        case "referred":
                            this.eventEmitter.emit(je.CLOSE), this.eventEmitter.emit(je.REFERRED);
                            break;
                        default:
                            console.warn("".concat("[CheckoutButton:Zipmoney]", " Unknown gateway status."))
                    }
                }
            }]), n
        }(),
        vt = "[Paydock:StorageDispatcher]";
    (ht || (ht = {})).WIDGET_SESSION = "widget-session";
    var mt, yt, gt = function() {
            function t(e) {
                g(this, t), this.messageSource = e, this.defaultPayload = {
                    destination: "widget.paydock"
                }, this.env = new re(Q), this.defaultPayload.source = e, this.iframeEvent = new Ie(window)
            }
            return d(t, [{
                key: "create",
                value: function(e) {
                    this.onLoadCallback = e, this.dispatcherFrame && this.destroy(), this.widgetId = ae.generate(), this.setupIframeEventListeners();
                    var t = document.createElement("iframe");
                    return t.setAttribute("src", this.env.getConf().url + "/storage-dispatcher" + "?widgetId=".concat(this.widgetId)), t.setAttribute("id", "pd-storage-dispatcher"), t.style.display = "none", document.body.appendChild(t), this.dispatcherFrame = t, console.info("".concat(vt, " initialized.")), t
                }
            }, {
                key: "destroy",
                value: function() {
                    this.dispatcherFrame && this.dispatcherFrame.parentNode && this.dispatcherFrame.parentNode.removeChild(this.dispatcherFrame), this.iframeEvent.clear(), this.widgetId = void 0, this.dispatcherFrame = void 0
                }
            }, {
                key: "push",
                value: function(e, t) {
                    var n;
                    if (this.pushCallbacks = t, this.dispatcherFrame) {
                        var i = R(R({}, this.defaultPayload), e);
                        null !== (n = this.dispatcherFrame.contentWindow) && void 0 !== n && n.postMessage(i, this.env.getConf().url)
                    } else console.error("".concat(vt, " dispatcher is not initialized."))
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.env.setEnv(e, t), this.create(this.onLoadCallback)
                }
            }, {
                key: "setupIframeEventListeners",
                value: function() {
                    var i = this;
                    this.widgetId && (this.iframeEvent.on(Le.AFTER_LOAD, this.widgetId, function(e) {
                        var t;
                        null !== (t = i.onLoadCallback) && void 0 !== t && t.call(i)
                    }), this.iframeEvent.on(Le.DISPATCH_SUCCESS, this.widgetId, function(e) {
                        var t, n;
                        null !== (n = null === (t = i.pushCallbacks) || void 0 === t ? void 0 : t.onSuccess) && void 0 !== n && n.call(t)
                    }), this.iframeEvent.on(Le.DISPATCH_ERROR, this.widgetId, function(e) {
                        var t, n;
                        null !== (n = null === (t = i.pushCallbacks) || void 0 === t ? void 0 : t.onError) && void 0 !== n && n.call(t)
                    }))
                }
            }]), t
        }(),
        kt = function() {
            u(n, ot(pt));
            var t = h(n);

            function n() {
                var e;
                return g(this, n), (e = t.call(this)).storageDispatcher = new gt("zipmoney.checkout.paydock"), e
            }
            return d(n, [{
                key: "getProxyRedirectUrl",
                value: function() {
                    return this.widgetEnv.getConf().url + "/checkout/zipmoney/response"
                }
            }, {
                key: "next",
                value: function(t, n) {
                    var i = this;
                    this.storageDispatcher.create(function() {
                        var e = {
                            merchant_redirect_url: i.getRedirectUrl(),
                            checkout_token: t.token,
                            public_key: n.public_key,
                            gateway_id: n.gateway_id
                        };
                        i.storageDispatcher.push({
                            intent: ht.WIDGET_SESSION,
                            data: e
                        }, {
                            onSuccess: function() {
                                var e = i.getCheckoutUri(t.link);
                                Zip.Checkout.init({
                                    checkoutUri: e,
                                    redirect: !0
                                })
                            },
                            onError: function() {
                                console.error("Error initializing Zip Checkout")
                            }
                        })
                    })
                }
            }, {
                key: "getSuccessRedirectUri",
                value: function() {
                    return this.getProxyRedirectUrl()
                }
            }, {
                key: "getErrorRedirectUri",
                value: function() {
                    return this.getProxyRedirectUrl()
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    l(c(n.prototype), "setEnv", this).call(this, e, t), this.storageDispatcher.setEnv(e, t)
                }
            }]), n
        }(),
        Et = function() {
            u(t, rt);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "getSuccessRedirectUri",
                value: function() {
                    return this.widgetEnv.getConf().url + oe.extendSearchParams("/checkout/success", "merchant", encodeURIComponent(window.location.href))
                }
            }, {
                key: "getErrorRedirectUri",
                value: function() {
                    return this.widgetEnv.getConf().url + oe.extendSearchParams("/checkout/error", "merchant", encodeURIComponent(window.location.href))
                }
            }]), t
        }(),
        _t = function() {
            u(t, rt);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "getSuccessRedirectUri",
                value: function() {
                    return this.widgetEnv.getConf().url + "/checkout/afterpay/merchant/{{merchant}}/success".replace("{{merchant}}", encodeURIComponent(window.btoa(window.location.href)))
                }
            }, {
                key: "getErrorRedirectUri",
                value: function() {
                    return this.widgetEnv.getConf().url + "/checkout/afterpay/merchant/{{merchant}}/error".replace("{{merchant}}", encodeURIComponent(window.btoa(window.location.href)))
                }
            }, {
                key: "next",
                value: function(e, t) {
                    this.checkout = e, Je.isSupportPopUp() || window.localStorage.setItem("paydock_checkout_token", JSON.stringify(this.checkout)), this.popup.redirect(this.getRedirectUrl(this.checkout, t))
                }
            }, {
                key: "error",
                value: function(e, t, n) {
                    return !t || t && "invalid_amount" !== t ? n(!0) : (this.popup.initError(e), n(!1))
                }
            }, {
                key: "run",
                value: function() {
                    this.isRunning() || (this.popup.setConfigs({
                        width: 420,
                        height: 715
                    }), this.popup.init(), this.background.initControl())
                }
            }, {
                key: "getRedirectUrl",
                value: function(e, t) {
                    return this.widgetEnv.getConf().url + "/checkout/afterpay/init?" + oe.serialize(R(R({}, t), {
                        token: e.reference_id,
                        env: "live" === e.mode ? "live" : "test"
                    }))
                }
            }]), t
        }(),
        wt = {
            EXTERNAL_CHECKOUT_TOKEN: "external_checkout_token",
            CHECKOUT_TOKEN: "checkout_token",
            BANK_ACCOUNT: "bank_account",
            CARD: "card"
        },
        bt = function() {
            u(o, qe);
            var r = h(o);

            function o(e, t) {
                var n, i = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : wt.CARD;
                switch (g(this, o), (n = r.call(this)).body = {
                        gateway_id: e,
                        type: i
                    }, i) {
                    case wt.CARD:
                    case wt.BANK_ACCOUNT:
                        delete t.gateway_id, delete t.type, delete t.checkout_token, n.body = R(n.body, t);
                        break;
                    case wt.CHECKOUT_TOKEN:
                    case wt.EXTERNAL_CHECKOUT_TOKEN:
                        n.body.checkout_token = t;
                        break;
                    default:
                        throw new Error("Unsupported type of PaymentSourceToken")
                }
                return n
            }
            return d(o, [{
                key: "getLink",
                value: function() {
                    return "/v1/payment_sources/tokens"
                }
            }, {
                key: "send",
                value: function(e, n, t) {
                    var i = 2 < arguments.length && void 0 !== t ? t : function(e) {};
                    this.create(e, this.getConfigs(), function(e, t) {
                        return n(e)
                    }, function(e, t) {
                        void 0 === e.message ? i("unknown error") : i(e.message)
                    })
                }
            }, {
                key: "getConfigs",
                value: function() {
                    return this.body
                }
            }]), o
        }(),
        Ct = function() {
            function o(e, t, n, i) {
                var r = this;
                g(this, o), this.background = e, this.runner = t, this.eventEmitter = n, this.params = i, this.runner.onStop(function() {
                    r.eventEmitter.emit(He.CLOSE)
                })
            }
            return d(o, [{
                key: "init",
                value: function(e) {
                    var t = this;
                    this.setEnv(e), this.runner.onCheckout(je.SUCCESS, function(e) {
                        t.eventEmitter.emit(He.ACCEPTED, {}), t.background.initLoader(), t.runner.stop(), t.checkToken(e.token, function() {
                            t.createOneTimeToken(e.token)
                        })
                    }), this.runner.onCheckout(je.ERROR, function() {
                        t.eventEmitter.emit(He.ERROR), console.error("".concat(ze, " Error from checkout server.")), t.runner.stop()
                    }), this.runner.onCheckout(je.REFERRED, function() {
                        t.eventEmitter.emit(He.REFERRED), t.runner.stop()
                    }), this.runner.onCheckout(je.DECLINED, function() {
                        t.eventEmitter.emit(He.DECLINED), t.runner.stop()
                    }), this.eventEmitter.subscribe(He.ERROR, function() {
                        t.runner.stop()
                    }), this.eventEmitter.subscribe(He.FINISH, function(e) {
                        t.background.clear()
                    })
                }
            }, {
                key: "setEnv",
                value: function(e) {
                    this.env = e
                }
            }, {
                key: "checkToken",
                value: function(e, t) {
                    var n = this,
                        i = new Ve(e);
                    i.setEnv(this.env), i.send(this.params.accessToken, function(e) {
                        n.details = e, t()
                    }, function() {
                        n.eventEmitter.emit(He.ERROR, {}), console.error("".concat(ze, " Error during creating payment source token."))
                    })
                }
            }, {
                key: "createOneTimeToken",
                value: function(e) {
                    var t = this,
                        n = new bt(this.params.gatewayId, e, wt.CHECKOUT_TOKEN);
                    n.setEnv(this.env), n.send(this.params.accessToken, function(e) {
                        t.eventEmitter.emit(He.FINISH, {
                            payment_source_token: e,
                            checkout_email: t.details.checkout_email,
                            checkout_holder: t.details.checkout_holder,
                            gateway_type: t.details.gateway_type
                        })
                    }, function() {
                        t.eventEmitter.emit(He.ERROR, {}), console.error("".concat(ze, " Error during creating payment source token."))
                    })
                }
            }]), o
        }(),
        St = function() {
            function o(e, t) {
                var n = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : "default",
                    i = 3 < arguments.length && void 0 !== arguments[3] ? arguments[3] : ke.PAYPAL,
                    r = 4 < arguments.length && void 0 !== arguments[4] ? arguments[4] : ye.CONTEXTUAL;
                g(this, o), this.accessToken = t, this.gatewayId = n, this.gatewayType = i, this.mode = r, this.window = window, this.meta = {}, this.env = te, this.eventEmitter = new We, this.container = new Pe(e), this.initCheckout(this.container), this.chooseRunner(i, r)
            }
            return d(o, [{
                key: "chooseRunner",
                value: function(e, t) {
                    var n = this.getRunnerByMode(e, t);
                    this.runner = new n(this.accessToken), at(this.runner) ? (this.background = new Qe, this.checkoutHandler = new Ct(this.background, this.runner, this.eventEmitter, {
                        accessToken: this.accessToken,
                        gatewayId: this.gatewayId
                    }), this.checkoutHandler.init(this.env)) : (this.background = void 0, this.checkoutHandler = void 0)
                }
            }, {
                key: "buildAdditionalParams",
                value: function() {
                    return {}
                }
            }, {
                key: "initCheckout",
                value: function(e) {
                    var n = this;
                    e.on("click", function(e) {
                        if (at(n.runner)) {
                            if (n.runner.isRunning()) return;
                            n.runner.run()
                        } else if (st(n.runner) && !n.runner.getRedirectUrl()) throw Error("".concat(ze, " The merchant redirect URL should is required in the '").concat(n.mode, "' mode."));
                        n.eventEmitter.emit(He.CLICK);
                        var t = new Ye(n.gatewayId, n.runner.getSuccessRedirectUri(), n.runner.getErrorRedirectUri());
                        t.setMeta(n.meta), t.setEnv(n.env), t.send(n.accessToken, function(e) {
                            var t = at(n.runner) ? He.POPUP_REDIRECT : He.REDIRECT;
                            n.eventEmitter.emit(t), n.runner.next(e, n.buildAdditionalParams())
                        }, function(e, t) {
                            console.error("".concat(ze, " ").concat(e)), n.eventEmitter.emit(He.ERROR, {
                                error: e,
                                code: t
                            }), n.runner.error(e, t, function(e) {
                                e && n.close()
                            })
                        })
                    })
                }
            }, {
                key: "on",
                value: function(e, t) {
                    this.eventEmitter.subscribe(e, t)
                }
            }, {
                key: "close",
                value: function() {
                    this.assertMethodSupport(this.runner, ye.CONTEXTUAL) && this.runner.stop()
                }
            }, {
                key: "onFinishInsert",
                value: function(t, n) {
                    this.on(He.FINISH, function(e) {
                        Re.insertToInput(t, n, e)
                    })
                }
            }, {
                key: "setMeta",
                value: function(e) {
                    this.meta = R(this.meta, e)
                }
            }, {
                key: "setBackdropDescription",
                value: function(e) {
                    this.assertMethodSupport(this.runner, ye.CONTEXTUAL) && this.runner.setBackgroundDescription(e)
                }
            }, {
                key: "setBackdropTitle",
                value: function(e) {
                    this.assertMethodSupport(this.runner, ye.CONTEXTUAL) && this.runner.setBackgroundTitle(e)
                }
            }, {
                key: "setSuspendedRedirectUri",
                value: function(e) {
                    this.assertMethodSupport(this.runner, ye.CONTEXTUAL) && this.runner.setSuspendedRedirectUri(e)
                }
            }, {
                key: "setRedirectUrl",
                value: function(e) {
                    this.assertMethodSupport(this.runner, ye.REDIRECT) && this.runner.setRedirectUrl(e)
                }
            }, {
                key: "getSuccessRedirectUri",
                value: function() {
                    return this.runner.getSuccessRedirectUri()
                }
            }, {
                key: "turnOffBackdrop",
                value: function() {
                    this.turnOffControlBackdrop(), this.turnOffLoaderBackdrop()
                }
            }, {
                key: "turnOffControlBackdrop",
                value: function() {
                    this.assertMethodSupport(this.runner, ye.CONTEXTUAL) && this.runner.turnOffBackdrop()
                }
            }, {
                key: "turnOffLoaderBackdrop",
                value: function() {
                    var e;
                    null !== (e = this.background) && void 0 !== e && e.turnOffLoader()
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    var n;
                    this.env = e, this.alias = t, null !== (n = this.checkoutHandler) && void 0 !== n && n.setEnv(e), this.runner.setEnv(e, t)
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.env
                }
            }, {
                key: "getRunnerByMode",
                value: function(e, t) {
                    if (e === ke.PAYPAL) {
                        if (t === ye.REDIRECT) throw Error("".concat(ze, " Gateway '").concat(e, "' do not support '").concat(t, "' mode"));
                        return Et
                    }
                    if (e === ke.AFTERPAY) {
                        if (t === ye.REDIRECT) throw Error("".concat(ze, " Gateway '").concat(e, "' do not support '").concat(t, "' mode"));
                        return _t
                    }
                    if (e === ke.ZIPMONEY) return t === ye.CONTEXTUAL ? ft : kt;
                    throw Error("".concat(ze, " Unsupported gateway."))
                }
            }, {
                key: "assertMethodSupport",
                value: function(e, t) {
                    var n = "".concat(ze, " The method is not supported in the '").concat(t, "' mode.");
                    switch (t) {
                        case ye.CONTEXTUAL:
                            if (at(e)) return !0;
                            console.warn(n);
                            break;
                        case ye.REDIRECT:
                            if (st(e)) return !0;
                            console.warn(n)
                    }
                    return !1
                }
            }]), o
        }(),
        Tt = function() {
            u(a, St);
            var o = h(a);

            function a(e, t) {
                var n, i = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : "default",
                    r = 3 < arguments.length && void 0 !== arguments[3] ? arguments[3] : ye.CONTEXTUAL;
                return g(this, a), (n = o.call(this, e, t, i, ke.ZIPMONEY, r)).publicKey = t, n.gatewayId = i, n.mode = r, n
            }
            return d(a, [{
                key: "setSuspendedRedirectUri",
                value: function(e) {
                    l(c(a.prototype), "setSuspendedRedirectUri", this).call(this, e)
                }
            }, {
                key: "setRedirectUrl",
                value: function(e) {
                    at(this.runner) && (l(c(a.prototype), "chooseRunner", this).call(this, ke.ZIPMONEY, ye.REDIRECT), l(c(a.prototype), "setEnv", this).call(this, this.env, this.alias)), l(c(a.prototype), "setRedirectUrl", this).call(this, e)
                }
            }, {
                key: "buildAdditionalParams",
                value: function() {
                    return R(R({}, l(c(a.prototype), "buildAdditionalParams", this).call(this)), {
                        public_key: this.publicKey,
                        gateway_id: this.gatewayId
                    })
                }
            }]), a
        }(),
        Ot = function() {
            u(o, St);
            var r = h(o);

            function o(e, t) {
                var n, i = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : "default";
                return g(this, o), (n = r.call(this, e, t, i, ke.AFTERPAY)).accessToken = t, n.gatewayId = i, n.showETP = !1, n
            }
            return d(o, [{
                key: "showEnhancedTrackingProtectionPopup",
                value: function(e) {
                    var t = Je.getBrowserInfo(),
                        n = t.name,
                        i = t.version;
                    e && "Firefox" === n && 100 <= +i && (this.showETP = !0)
                }
            }, {
                key: "buildAdditionalParams",
                value: function() {
                    var e = l(c(o.prototype), "buildAdditionalParams", this).call(this);
                    return this.showETP && (e.show_etp = !0), e
                }
            }]), o
        }(),
        At = function() {
            u(o, St);
            var r = h(o);

            function o(e, t) {
                var n, i = 2 < arguments.length && void 0 !== arguments[2] ? arguments[2] : "default";
                return g(this, o), (n = r.call(this, e, t, i, ke.PAYPAL)).publicKey = t, n.gatewayId = i, n
            }
            return d(o)
        }();
    (yt = mt = mt || {}).AFTER_LOAD = "after_load", yt.UNAVAILABLE = "unavailable", yt.START_LOADING = "start_loading", yt.END_LOADING = "end_loading", yt.UPDATE = "update", yt.PAYMENT_SUCCESSFUL = "payment_successful", yt.PAYMENT_IN_REVIEW = "payment_in_review", yt.PAYMENT_ERROR = "payment_error";
    var Rt = function() {
            u(t, Ie);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "on",
                value: function(e, t, n) {
                    for (var i in mt) mt.hasOwnProperty(i) && e === mt[i] && this.listeners.push({
                        event: e,
                        listener: n,
                        widget_id: t
                    })
                }
            }]), t
        }(),
        Pt = {
            CLOSE: "close",
            UPDATED: "updated"
        },
        xt = function() {
            u(r, De);
            var i = h(r);

            function r(e, t) {
                var n;
                return g(this, r), (n = i.call(this, e)).widgetId = t, n
            }
            return d(r, [{
                key: "push",
                value: function(e, t) {
                    var n = 1 < arguments.length && void 0 !== t ? t : {};
                    if (this.iFrame.isExist()) {
                        -1 === ce.values(Pt).indexOf(e) && console.warn("unsupported trigger type");
                        var i = {
                            message_source: "wallet.paydock",
                            reference_id: this.widgetId,
                            trigger: e,
                            destination: "widget.paydock",
                            data: n
                        };
                        this.iFrame.getElement().contentWindow.postMessage(JSON.stringify(i), "*")
                    }
                }
            }]), r
        }(),
        Lt = function() {
            u(i, Qe);
            var n = h(i);

            function i(e) {
                var t;
                return g(this, i), (t = n.call(this)).bgImageUrl = e, t.imageStyle = null, t
            }
            return d(i, [{
                key: "initControl",
                value: function() {
                    this.imageStyle || this.createImageStyles(), l(c(i.prototype), "initControl", this).call(this)
                }
            }, {
                key: "clear",
                value: function() {
                    this.imageStyle && this.imageStyle.parentNode.removeChild(this.imageStyle), this.imageStyle = null, l(c(i.prototype), "clear", this).call(this)
                }
            }, {
                key: "createTemplate",
                value: function() {
                    var e = this,
                        t = document.body || document.getElementsByTagName("body")[0],
                        n = String('\n    <div class="checkout-container">\n        <div class="checkout-bg-logo"></div>\n        <a href="#" data-close>Close</a>\n    </div>\n');
                    this.overlay = document.createElement("div"), this.overlay.classList.add("checkout-overlay"), this.overlay.setAttribute("checkout-overlay", " "), this.overlay.innerHTML = n, t.appendChild(this.overlay), setTimeout(function() {
                        e.isInit() && e.overlay.classList.add("display")
                    }, 5)
                }
            }, {
                key: "createImageStyles",
                value: function() {
                    var e = document.head || document.getElementsByTagName("head")[0],
                        t = String("\n    .checkout-bg-logo {\n        display: block;\n        background: url({{url}}) no-repeat;\n        width: 100px;\n        height: 50px;\n        margin: 0 auto;\n        border-radius: 10px;\n        background-size: contain;\n    }\n");
                    document.querySelector(".checkout-container");
                    t = t.replace("{{url}}", this.bgImageUrl), this.imageStyle = document.createElement("style"), this.imageStyle.type = "text/css", this.imageStyle.appendChild(document.createTextNode(t)), e.appendChild(this.imageStyle)
                }
            }]), i
        }(),
        It = {
            UNAVAILABLE: "unavailable",
            UPDATE: "update",
            PAYMENT_METHOD_SELECTED: "payment_method_selected",
            PAYMENT_SUCCESS: "payment_success",
            PAYMENT_IN_REVIEW: "payment_in_review",
            PAYMENT_ERROR: "payment_error",
            CALLBACK: "callback",
            AUTH_TOKENS_CHANGED: "auth_tokens_changed"
        },
        Ut = function() {
            function n(e, t) {
                g(this, n), this.publicKey = e, this.meta = t, this.env = te, this.eventEmitter = new We, this.initializeChildWallets()
            }
            return d(n, [{
                key: "initializeChildWallets",
                value: function() {
                    this.childWallets = []
                }
            }, {
                key: "getGatewayName",
                value: function() {
                    throw new Error("Method not implemented")
                }
            }, {
                key: "setEnv",
                value: function(e) {
                    return this.env = e, this
                }
            }, {
                key: "load",
                value: function(t) {
                    this.childWallets.forEach(function(e) {
                        return e.load(t)
                    })
                }
            }, {
                key: "update",
                value: function() {}
            }, {
                key: "on",
                value: function(e, t) {
                    var n = this;
                    if (-1 === ce.values(It).indexOf(e)) throw new Error("invalid wallet event");
                    return "function" == typeof t ? this.eventEmitter.subscribe(e, t) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(e, function(e) {
                            return t(e)
                        })
                    })
                }
            }]), n
        }(),
        Dt = function() {
            u(l, Ut);
            var c = h(l);

            function l(e, t) {
                var n;
                g(this, l), (n = c.call(this, e, t)).link = new ue(se);
                var i = t.amount,
                    r = t.currency,
                    o = t.id,
                    a = t.gateway_mode,
                    s = t.reference,
                    u = t.request_shipping;
                return n.link.setParams(R({
                    token: e,
                    amount: i,
                    currency: r,
                    gateway_mode: a,
                    credentials: s || o
                }, u ? {
                    request_shipping: u
                } : {})), w.version && n.link.setParams({
                    sdk_version: w.version,
                    sdk_type: w.type
                }), n.token = e, n.event = new Rt(window), n
            }
            return d(l, [{
                key: "load",
                value: function(e) {
                    this.container = e, this.iFrame = new xe(this.container);
                    var t = this.link.getParams().widget_id;
                    this.triggerElement = new xt(this.iFrame, t), this.setupIFrameEvents(t), this.background = this.initBackground(), this.iFrame.load(this.link.getUrl())
                }
            }, {
                key: "close",
                value: function() {
                    this.triggerElement.push(Pt.CLOSE), this.background.clear()
                }
            }, {
                key: "update",
                value: function(e) {
                    this.triggerElement.push(Pt.UPDATED, e)
                }
            }, {
                key: "setEnv",
                value: function(e) {
                    return this.link.setEnv(e), this
                }
            }, {
                key: "initBackground",
                value: function() {
                    var e = this,
                        t = new Lt(this.link.getNetUrl().replace(se, "/images/logo.png"));
                    return t.setBackdropTitle(""), t.setBackdropDescription(""), t.onTrigger(Xe, function() {
                        return e.triggerElement.push(Pt.CLOSE)
                    }), t
                }
            }, {
                key: "setupIFrameEvents",
                value: function(e) {
                    var t = this;
                    this.event.on(mt.UNAVAILABLE, e, function(e) {
                        return t.eventEmitter.emit(It.UNAVAILABLE, null)
                    }), this.event.on(mt.START_LOADING, e, function(e) {
                        return t.background.initControl()
                    }), this.event.on(mt.END_LOADING, e, function(e) {
                        return t.background.clear()
                    }), this.event.on(mt.UPDATE, e, function(e) {
                        t.eventEmitter.emit(It.UPDATE, t.parseUpdateData(e))
                    }), this.event.on(mt.PAYMENT_SUCCESSFUL, e, function(e) {
                        t.eventEmitter.emit(It.PAYMENT_SUCCESS, t.parsePaymentSuccessfulData(e)), t.iFrame.getElement() || t.background.clear()
                    }), this.event.on(mt.PAYMENT_IN_REVIEW, e, function(e) {
                        t.eventEmitter.emit(It.PAYMENT_IN_REVIEW, t.parsePaymentSuccessfulData(e)), t.iFrame.getElement() || t.background.clear()
                    }), this.event.on(mt.PAYMENT_ERROR, e, function(e) {
                        t.eventEmitter.emit(It.PAYMENT_ERROR, e), t.iFrame.getElement() || t.background.clear()
                    })
                }
            }, {
                key: "parsePaymentSuccessfulData",
                value: function(e) {
                    var t;
                    return {
                        id: this.meta.id,
                        amount: e.amount,
                        currency: e.currencyCode,
                        status: null === (t = e.charge) || void 0 === t ? void 0 : t.status
                    }
                }
            }, {
                key: "parseUpdateData",
                value: function(e) {
                    return R(R(R({
                        wallet_response_code: e.responseCode,
                        wallet_session_id: e.sessionId
                    }, e.paymentMethodDetails ? {
                        payment_source: {
                            wallet_payment_method_id: e.paymentMethodDetails.paymentMethodId,
                            card_number_last4: e.paymentMethodDetails.lastFourDigitsOfPan,
                            card_scheme: e.paymentMethodDetails.paymentScheme
                        }
                    } : {}), e.loyaltyAccountSummary ? {
                        wallet_loyalty_account: {
                            id: e.loyaltyAccountSummary.loyaltyAccountId,
                            barcode: e.loyaltyAccountSummary.loyaltyAccountBarcode
                        }
                    } : {}), e.deliveryAddressDetails ? {
                        shipping: {
                            address_line1: e.deliveryAddressDetails.line1,
                            address_line2: e.deliveryAddressDetails.line2,
                            address_postcode: e.deliveryAddressDetails.postalCode,
                            address_city: e.deliveryAddressDetails.city,
                            address_state: e.deliveryAddressDetails.state,
                            address_country: e.deliveryAddressDetails.countryCode,
                            address_company: e.deliveryAddressDetails.companyName,
                            wallet_address_id: e.deliveryAddressDetails.addressId,
                            post_office_box_number: e.deliveryAddressDetails.postOfficeBoxNumber,
                            wallet_address_created_timestamp: e.deliveryAddressDetails.createdTimestamp,
                            wallet_address_updated_timestamp: e.deliveryAddressDetails.updatedTimestamp,
                            wallet_address_name: e.deliveryAddressDetails.name
                        }
                    } : {})
                }
            }]), l
        }(),
        Nt = function() {
            u(t, Ut);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "load",
                value: function(e) {
                    return window.Promise ? !0 === this.meta.standalone ? this.renderPaypalStandaloneComponent(e) : this.renderPaypalCommonComponent(e) : this.eventEmitter.emit(It.UNAVAILABLE, null), Promise.resolve()
                }
            }, {
                key: "update",
                value: function(e) {
                    var t = this;
                    if (this.latestShippingChangePromiseResolve && this.latestShippingChangePromiseReject) return e.success ? void this.eventEmitter.emit(It.CALLBACK, {
                        data: {
                            request_type: "UPDATE_TRANSACTION",
                            shipping: this.latestShippingData
                        },
                        onSuccess: function() {
                            return t.latestShippingChangePromiseResolve(!0)
                        },
                        onError: function() {
                            return t.latestShippingChangePromiseReject()
                        }
                    }) : this.latestShippingChangePromiseReject()
                }
            }, {
                key: "renderPaypalCommonComponent",
                value: function(e) {
                    var t, n = this,
                        i = (null === (t = e.getElement()) || void 0 === t ? void 0 : t.id) || "",
                        r = document.createElement("script");
                    r.src = "https://www.paypal.com/sdk/js?client-id=".concat(this.publicKey, "&currency=").concat(this.meta.currency).concat(!0 === this.meta.pay_later ? "&enable-funding=paylater&disable-funding=card" : "&disable-funding=credit,card").concat(this.meta.capture ? "" : "&intent=authorize"), r.async = !0, r.onload = function() {
                        window.paypal ? (n.paypal = window.paypal, n.paypal.Buttons(R({}, n.paypalSharedProps())).render("#".concat(i))) : n.eventEmitter.emit(It.UNAVAILABLE, null)
                    }, document.head.appendChild(r)
                }
            }, {
                key: "renderPaypalStandaloneComponent",
                value: function(e) {
                    var t, n, i = this,
                        r = (null === (t = e.getElement()) || void 0 === t ? void 0 : t.id) || "",
                        o = document.createElement("script");
                    o.src = "https://www.paypal.com/sdk/js?client-id=".concat(this.publicKey, "&currency=").concat(this.meta.currency, "&components=buttons,funding-eligibility,messages&enable-funding=paylater").concat(this.meta.capture ? "" : "&intent=authorize").concat("live" === (null === (n = this.meta) || void 0 === n ? void 0 : n.gateway_mode) ? "" : "&buyer-country=AU"), o.async = !0, o.onload = function() {
                        if (window.paypal) {
                            i.paypal = window.paypal;
                            var e = !!i.meta.pay_later,
                                t = i.paypal.Buttons(R({
                                    fundingSource: e ? i.paypal.FUNDING.PAYLATER : i.paypal.FUNDING.PAYPAL
                                }, i.paypalSharedProps()));
                            if (t.isEligible()) {
                                if (t.render("#".concat(r)), e) i.paypal.Messages(R({
                                    amount: i.meta.amount,
                                    currency: i.meta.currency,
                                    placement: "payment"
                                }, i.meta.style && i.meta.style.messages && {
                                    style: i.meta.style.messages
                                })).render("#".concat(r))
                            } else i.eventEmitter.emit(It.UNAVAILABLE, null)
                        } else i.eventEmitter.emit(It.UNAVAILABLE, null)
                    }, document.head.appendChild(o)
                }
            }, {
                key: "paypalSharedProps",
                value: function() {
                    var r = this;
                    return R(R({}, this.meta.style && {
                        style: this.meta.style
                    }), {
                        createOrder: function() {
                            return new Promise(function(t, n) {
                                r.eventEmitter.emit(It.CALLBACK, {
                                    data: R({
                                        request_type: "CREATE_TRANSACTION"
                                    }, r.meta.request_shipping && {
                                        request_shipping: r.meta.request_shipping
                                    }),
                                    onSuccess: function(e) {
                                        return t(e.id)
                                    },
                                    onError: function(e) {
                                        return n(e)
                                    }
                                })
                            })
                        },
                        onShippingChange: function(i) {
                            return new Promise(function(e, t) {
                                var n = r.parseUpdateData(i);
                                r.latestShippingData = n.shipping, r.latestShippingChangePromiseResolve = e, r.latestShippingChangePromiseReject = t, r.eventEmitter.emit(It.UPDATE, n)
                            })
                        },
                        onApprove: function(n) {
                            return r.pendingApprovalPromise = r.pendingApprovalPromise || new Promise(function(e, t) {
                                return r.eventEmitter.emit(It.PAYMENT_METHOD_SELECTED, {
                                    data: {
                                        payment_method_id: n.orderID,
                                        customer: {
                                            payment_source: {
                                                external_payer_id: n.payerID
                                            }
                                        }
                                    },
                                    onSuccess: function() {
                                        r.pendingApprovalPromise = void 0, e(!0)
                                    },
                                    onError: function(e) {
                                        r.pendingApprovalPromise = void 0, t(e)
                                    }
                                })
                            }), r.pendingApprovalPromise
                        },
                        onError: function() {}
                    })
                }
            }, {
                key: "parseUpdateData",
                value: function(e) {
                    var t;
                    return R(R({
                        wallet_order_id: e.orderID,
                        wallet_session_id: e.paymentID,
                        payment_source: {
                            wallet_payment_method_id: e.paymentToken
                        }
                    }, e.shipping_address && {
                        shipping: {
                            address_city: e.shipping_address.city,
                            address_state: e.shipping_address.state,
                            address_postcode: e.shipping_address.postal_code,
                            address_country: e.shipping_address.country_code
                        }
                    }), e.selected_shipping_option && {
                        selected_shipping_option: {
                            id: e.selected_shipping_option.id,
                            label: e.selected_shipping_option.label,
                            amount: e.selected_shipping_option.amount.value,
                            currency: e.selected_shipping_option.amount.currency_code,
                            type: null === (t = e.selected_shipping_option) || void 0 === t ? void 0 : t.type
                        }
                    })
                }
            }]), t
        }(),
        Mt = dt(function(e, t) {
            function n(e) {
                return (n = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(e) {
                    return typeof e
                } : function(e) {
                    return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
                })(e)
            }
            Object.defineProperty(t, "__esModule", {
                value: !0
            });

            function r(i) {
                return null !== c ? c : c = new Promise(function(e, t) {
                    if ("undefined" != typeof window)
                        if (window.Stripe && i && console.warn(u), window.Stripe) e(window.Stripe);
                        else try {
                            var n = function() {
                                for (var e = document.querySelectorAll('script[src^="'.concat(a, '"]')), t = 0; t < e.length; t++) {
                                    var n = e[t];
                                    if (s.test(n.src)) return n
                                }
                                return null
                            }();
                            n && i ? console.warn(u) : n = n || function(e) {
                                var t = e && !e.advancedFraudSignals ? "?advancedFraudSignals=false" : "",
                                    n = document.createElement("script");
                                n.src = "".concat(a).concat(t);
                                var i = document.head || document.body;
                                if (!i) throw new Error("Expected document.body not to be null. Stripe.js requires a <body> element.");
                                return i.appendChild(n), n
                            }(i), n.addEventListener("load", function() {
                                window.Stripe ? e(window.Stripe) : t(new Error("Stripe.js not available"))
                            }), n.addEventListener("error", function() {
                                t(new Error("Failed to load Stripe.js"))
                            })
                        } catch (e) {
                            return void t(e)
                        } else e(null)
                })
            }

            function i() {
                for (var e = arguments.length, t = new Array(e), n = 0; n < e; n++) t[n] = arguments[n];
                l = !0;
                var i = Date.now();
                return r(o).then(function(e) {
                    return function(e, t, n) {
                        if (null === e) return null;
                        var i, r, o = e.apply(void 0, t);
                        return r = n, (i = o) && i._registerWrapper && i._registerWrapper({
                            name: "stripe-js",
                            version: "1.11.0",
                            startTime: r
                        }), o
                    }(e, t, i)
                })
            }
            var o, a = "https://js.stripe.com/v3",
                s = /^https:\/\/js\.stripe\.com\/v3\/?(\?.*)?$/,
                u = "loadStripe.setLoadParameters was called but an existing Stripe.js script already exists in the document; existing script parameters will be used",
                c = null,
                l = !1;
            i.setLoadParameters = function(e) {
                if (l) throw new Error("You cannot change load parameters after calling loadStripe");
                o = function(e) {
                    var t = "invalid load parameters; expected object of shape\n\n    {advancedFraudSignals: boolean}\n\nbut received\n\n    ".concat(JSON.stringify(e), "\n");
                    if (null === e || "object" !== n(e)) throw new Error(t);
                    if (1 === Object.keys(e).length && "boolean" == typeof e.advancedFraudSignals) return e;
                    throw new Error(t)
                }(e)
            }, t.loadStripe = i
        });
    lt(Mt);
    Mt.loadStripe;
    var Ft, Ht, jt = Mt.loadStripe,
        Bt = "success",
        zt = "fail",
        qt = function() {
            u(t, Ut);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "initPaymentRequest",
                value: function() {
                    return this.stripe.paymentRequest({
                        country: this.meta.country.toUpperCase(),
                        currency: this.meta.currency.toLowerCase(),
                        total: {
                            label: this.meta.amount_label,
                            amount: Math.floor(100 * this.meta.amount)
                        },
                        requestPayerName: !0 === this.meta.request_payer_name,
                        requestPayerEmail: !0 === this.meta.request_payer_email,
                        requestPayerPhone: !0 === this.meta.request_payer_phone
                    })
                }
            }, {
                key: "createWalletButton",
                value: function() {
                    return this.stripe.elements().create("paymentRequestButton", {
                        paymentRequest: this.paymentRequest
                    })
                }
            }, {
                key: "load",
                value: function(t) {
                    var n = this;
                    return jt(this.publicKey).then(function(e) {
                        n.stripe = e, n.paymentRequest = n.initPaymentRequest()
                    }).then(function() {
                        return n.checkAvailability()
                    }).then(function(e) {
                        return n.mount(t, e)
                    }).then(function() {
                        return n.setOnPaymentMethodSelected()
                    })
                }
            }, {
                key: "checkAvailability",
                value: function() {
                    var i = this;
                    return this.paymentRequest.canMakePayment().then(function(e) {
                        if (e) {
                            var t = !i.meta.wallets || i.meta.wallets.includes(P.GOOGLE),
                                n = !i.meta.wallets || i.meta.wallets.includes(P.APPLE);
                            return {
                                google_pay: t && !e.applePay,
                                apple_pay: n && e.applePay,
                                flypay: !1
                            }
                        }
                    })
                }
            }, {
                key: "mount",
                value: function(e, t) {
                    if (!t || !t.apple_pay && !t.google_pay) return this.eventEmitter.emit(It.UNAVAILABLE, null);
                    this.createWalletButton().mount(e.getElement())
                }
            }, {
                key: "setOnPaymentMethodSelected",
                value: function() {
                    var l = this;
                    this.paymentRequest.on("paymentmethod", function(e) {
                        var t, n, i = e.paymentMethod,
                            r = i.id,
                            o = i.card,
                            a = i.billing_details,
                            s = a.name,
                            u = a.address,
                            c = {
                                payment_method_id: r,
                                customer: {
                                    payer_name: e.payerName,
                                    payer_email: e.payerEmail,
                                    payer_phone: e.payerPhone,
                                    payment_source: {
                                        wallet_type: l.getWalletType(null === (t = null == o ? void 0 : o.wallet) || void 0 === t ? void 0 : t.type),
                                        card_name: s,
                                        type: null === (n = null == o ? void 0 : o.wallet) || void 0 === n ? void 0 : n.type,
                                        card_scheme: null == o ? void 0 : o.brand,
                                        card_number_last4: null == o ? void 0 : o.last4,
                                        expire_month: null == o ? void 0 : o.exp_month,
                                        expire_year: null == o ? void 0 : o.exp_year,
                                        address_line1: u.line1,
                                        address_line2: u.line2,
                                        address_city: u.city,
                                        address_postcode: u.postal_code,
                                        address_state: u.state,
                                        address_country: u.country
                                    }
                                }
                            };
                        l.eventEmitter.emit(It.PAYMENT_METHOD_SELECTED, {
                            data: c,
                            onSuccess: function() {
                                return e.complete(Bt)
                            },
                            onError: function() {
                                return e.complete(zt)
                            }
                        })
                    })
                }
            }, {
                key: "getWalletType",
                value: function(e) {
                    return e ? "google_pay" === e ? P.GOOGLE : P.APPLE : null
                }
            }]), t
        }(),
        Yt = function() {
            u(o, Ut);
            var r = h(o);

            function o(e, t, n, i) {
                var u;
                return g(this, o), (u = r.call(this, e, t)).gatewayName = n, u.eventEmitter = i, u.latestShippingData = {}, u.onValidateMerchant = function(e) {
                    u.getMerchantSession().then(function(e) {
                        u.paymentSession.completeMerchantValidation(e)
                    }).catch(function(e) {
                        return console.error("Error fetching merchant session", e)
                    })
                }, u.onPaymentAuthorized = function(e) {
                    var t, n = e.payment,
                        i = n.token,
                        r = n.billingContact,
                        o = n.shippingContact;
                    u.latestShippingData.shippingContact = o;
                    var a = null === (t = u.selectedShippingOption) || void 0 === t ? void 0 : t.type,
                        s = [null == o ? void 0 : o.givenName, null == o ? void 0 : o.familyName].join(" ").trim();
                    u.eventEmitter.emit(It.PAYMENT_METHOD_SELECTED, {
                        data: R({
                            customer: {
                                payment_source: R(R({
                                    wallet_type: P.APPLE
                                }, s && {
                                    card_name: s
                                }), {
                                    type: i.paymentMethod.type,
                                    card_scheme: i.paymentMethod.network,
                                    address_line1: null == r ? void 0 : r.addressLines[0],
                                    address_line2: null == r ? void 0 : r.addressLines[1],
                                    address_country: null == r ? void 0 : r.countryCode,
                                    address_city: null == r ? void 0 : r.locality,
                                    address_postcode: null == r ? void 0 : r.postalCode,
                                    address_state: null == r ? void 0 : r.administrativeArea,
                                    ref_token: i.paymentData ? JSON.stringify(i.paymentData) : ""
                                })
                            }
                        }, u.meta.request_shipping && o && {
                            shipping: R(R(R({}, a && {
                                method: a
                            }), u.hasShippingOptions() && {
                                options: u.meta.shipping_options
                            }), {
                                address_line1: o.addressLines[0],
                                address_line2: o.addressLines[1],
                                address_country: o.countryCode,
                                address_city: o.locality,
                                address_postcode: o.postalCode,
                                address_state: o.administrativeArea,
                                contact: {
                                    first_name: o.givenName,
                                    last_name: o.familyName,
                                    email: o.emailAddress,
                                    phone: o.phoneNumber
                                }
                            })
                        }),
                        onSuccess: function() {
                            return u.paymentSession.completePayment(ApplePaySession.STATUS_SUCCESS)
                        },
                        onError: function() {
                            return u.paymentSession.completePayment(ApplePaySession.STATUS_FAILURE)
                        }
                    })
                }, u.onShippingContactSelected = function(e) {
                    u.latestShippingData.shippingContact = e.shippingContact;
                    var t = u.parseUpdateData(u.latestShippingData);
                    return u.eventEmitter.emit(It.UPDATE, t), new Promise(function(e, t) {
                        u.latestShippingChangePromiseResolve = e, u.latestShippingChangePromiseReject = t
                    })
                }, u.onShippingMethodSelected = function(e) {
                    var t, n;
                    u.latestShippingData.shippingMethod = e.shippingMethod;
                    var i = {
                        newTotal: {
                            label: u.meta.amount_label || (null === (n = null === (t = u.getMetaRawDataInitialization()) || void 0 === t ? void 0 : t.total) || void 0 === n ? void 0 : n.label),
                            amount: u.meta.amount.toString(),
                            type: "final"
                        }
                    };
                    u.paymentSession.completeShippingMethodSelection(i)
                }, u.parseUpdateData = function(e) {
                    var t, n, i, r, o, a, s, u;
                    return R({
                        shipping: {
                            address_city: null === (t = null == e ? void 0 : e.shippingContact) || void 0 === t ? void 0 : t.locality,
                            address_state: null === (n = null == e ? void 0 : e.shippingContact) || void 0 === n ? void 0 : n.administrativeArea,
                            address_postcode: null === (i = null == e ? void 0 : e.shippingContact) || void 0 === i ? void 0 : i.postalCode,
                            address_country: null === (r = null == e ? void 0 : e.shippingContact) || void 0 === r ? void 0 : r.countryCode
                        }
                    }, (null == e ? void 0 : e.shippingMethod) && {
                        selected_shipping_option: {
                            id: null === (o = null == e ? void 0 : e.shippingMethod) || void 0 === o ? void 0 : o.identifier,
                            label: null === (a = null == e ? void 0 : e.shippingMethod) || void 0 === a ? void 0 : a.label,
                            detail: null === (s = null == e ? void 0 : e.shippingMethod) || void 0 === s ? void 0 : s.detail,
                            amount: null === (u = null == e ? void 0 : e.shippingMethod) || void 0 === u ? void 0 : u.amount
                        }
                    })
                }, u.formatShippingOptions = function(e) {
                    return e.map(function(e) {
                        return {
                            identifier: e.id,
                            label: e.label,
                            detail: (null == e ? void 0 : e.detail) || "",
                            amount: e.amount
                        }
                    })
                }, u.eventEmitter = i, u
            }
            return d(o, [{
                key: "getGatewayName",
                value: function() {
                    return this.gatewayName
                }
            }, {
                key: "getMerchantId",
                value: function() {
                    var e, t, n;
                    return (null === (n = null === (t = null === (e = this.meta) || void 0 === e ? void 0 : e.credentials) || void 0 === t ? void 0 : t[P.APPLE]) || void 0 === n ? void 0 : n.merchant) || ""
                }
            }, {
                key: "getMetaStyles",
                value: function() {
                    var e, t, n;
                    if (null !== (e = this.meta) && void 0 !== e && e.style && "object" === K(null === (t = this.meta) || void 0 === t ? void 0 : t.style)) {
                        var i = JSON.parse(JSON.stringify(null === (n = this.meta) || void 0 === n ? void 0 : n.style));
                        return "google" in i && (null == i || delete i.google), "apple" in i ? null == i ? void 0 : i.apple : i
                    }
                    return null
                }
            }, {
                key: "getMetaRawDataInitialization",
                value: function() {
                    var e, t, n, i;
                    if (null !== (e = this.meta) && void 0 !== e && e.raw_data_initialization && null !== (t = this.meta) && void 0 !== t && t.raw_data_initialization && "object" === K(null === (n = this.meta) || void 0 === n ? void 0 : n.raw_data_initialization)) {
                        var r = JSON.parse(JSON.stringify(null === (i = this.meta) || void 0 === i ? void 0 : i.raw_data_initialization));
                        return "google" in r && (null == r || delete r.google), "apple" in r ? null == r ? void 0 : r.apple : r
                    }
                    return null
                }
            }, {
                key: "isShippingRequired",
                value: function() {
                    var e;
                    return null === (e = this.meta) || void 0 === e ? void 0 : e.request_shipping
                }
            }, {
                key: "hasShippingOptions",
                value: function() {
                    var e, t;
                    return (null === (e = this.meta) || void 0 === e ? void 0 : e.request_shipping) && !(null === (t = this.meta) || void 0 === t || !t.shipping_options)
                }
            }, {
                key: "load",
                value: function(n) {
                    var i = this;
                    if (window.Promise) return this.checkAvailability().then(function(e) {
                        var t;
                        e ? (i.isShippingRequired() && i.hasShippingOptions() && (i.selectedShippingOption = null === (t = i.meta) || void 0 === t ? void 0 : t.shipping_options[0], i.latestShippingData.shippingMethod = i.formatShippingOptions([i.selectedShippingOption])[0]), i.mount(n)) : i.eventEmitter.emit(It.UNAVAILABLE, {
                            wallet: P.APPLE
                        })
                    }).catch(function(e) {
                        return console.error("Error checking ApplePay availability", e)
                    });
                    this.eventEmitter.emit(It.UNAVAILABLE, {
                        wallet: P.APPLE
                    })
                }
            }, {
                key: "update",
                value: function(e) {
                    var t, n, i;
                    if (this.latestShippingChangePromiseResolve && this.latestShippingChangePromiseReject) {
                        if (!e.success || !e.body) return this.latestShippingChangePromiseReject();
                        var r = null === (t = null == e ? void 0 : e.body) || void 0 === t ? void 0 : t.amount,
                            o = null === (n = null == e ? void 0 : e.body) || void 0 === n ? void 0 : n.shipping_options;
                        r && (this.meta.amount = r), o && (this.meta.shipping_options = o, this.selectedShippingOption = o ? o[0] : void 0);
                        var a = R({
                            newTotal: {
                                label: null === (i = this.meta) || void 0 === i ? void 0 : i.amount_label,
                                amount: this.meta.amount.toString(),
                                type: "final"
                            }
                        }, this.isShippingRequired() && this.hasShippingOptions() && {
                            newShippingMethods: this.formatShippingOptions(this.meta.shipping_options)
                        });
                        this.paymentSession.completeShippingContactSelection(a), this.latestShippingChangePromiseResolve({})
                    }
                }
            }, {
                key: "checkAvailability",
                value: function() {
                    var n = this;
                    return new Promise(function(t, e) {
                        window.ApplePaySession && ApplePaySession || t(!1), ApplePaySession.canMakePaymentsWithActiveCard(n.getMerchantId()).then(function(e) {
                            return t(e)
                        }).catch(function(e) {
                            return t(!1)
                        })
                    })
                }
            }, {
                key: "mount",
                value: function(e) {
                    var t = this,
                        n = document.createElement("style");
                    n.innerHTML = this.createButtonStyle(), document.head.appendChild(n);
                    var i = document.createElement("div");
                    i.onclick = function() {
                        return t.onApplePayButtonClicked()
                    }, i.classList.add("paydock-apple-container", "apple-pay-button", "apple-pay-button-black"), i.setAttribute("tabindex", "0"), i.setAttribute("role", "button"), e.getElement().appendChild(i)
                }
            }, {
                key: "onApplePayButtonClicked",
                value: function() {
                    this.paymentSession = new ApplePaySession(3, this.createRequest()), this.paymentSession.onvalidatemerchant = this.onValidateMerchant, this.paymentSession.onpaymentauthorized = this.onPaymentAuthorized, this.paymentSession.onshippingcontactselected = this.onShippingContactSelected, this.paymentSession.onshippingmethodselected = this.onShippingMethodSelected, this.paymentSession.begin()
                }
            }, {
                key: "createRequest",
                value: function() {
                    var e, t = this.getMetaRawDataInitialization();
                    return t && "object" === K(t) && ("object" === K(t.total) ? t.total.amount = this.meta.amount.toString() : t.total = {
                        label: (null === (e = this.meta) || void 0 === e ? void 0 : e.amount_label) || "",
                        amount: this.meta.amount.toString()
                    }, this.isShippingRequired() && this.hasShippingOptions() && (t.shippingMethods = this.formatShippingOptions(this.meta.shipping_options))), t || R(R(R({
                        countryCode: this.meta.country.toUpperCase(),
                        currencyCode: this.meta.currency.toUpperCase(),
                        merchantCapabilities: ["supports3DS", "supportsCredit", "supportsDebit"],
                        supportedNetworks: ["visa", "masterCard", "amex", "discover"]
                    }, this.meta.show_billing_address && {
                        requiredBillingContactFields: ["name", "postalAddress"]
                    }), this.isShippingRequired() && R({
                        requiredShippingContactFields: ["postalAddress", "name", "phone", "email"]
                    }, this.hasShippingOptions() && {
                        shippingMethods: this.formatShippingOptions(this.meta.shipping_options)
                    })), {
                        total: {
                            label: this.meta.amount_label,
                            amount: this.meta.amount.toString(),
                            type: "final"
                        }
                    })
                }
            }, {
                key: "getMerchantSession",
                value: function() {
                    var e = this;
                    return new Promise(function(t, n) {
                        return e.eventEmitter.emit(It.CALLBACK, {
                            data: R({
                                request_type: "CREATE_SESSION",
                                wallet_type: P.APPLE,
                                session_id: window.location.hostname
                            }, e.isShippingRequired() && {
                                request_shipping: e.meta.request_shipping
                            }),
                            onSuccess: function(e) {
                                return t(e)
                            },
                            onError: function(e) {
                                return n(e)
                            }
                        })
                    })
                }
            }, {
                key: "createButtonStyle",
                value: function() {
                    var e, t;
                    return "\n            .paydock-apple-container {\n                width: 100%;\n                height: 40px;\n            }\n\n            @supports (-webkit-appearance: -apple-pay-button) {\n                .apple-pay-button {\n                    display: inline-block;\n                    -webkit-appearance: -apple-pay-button;\n                    -apple-pay-button-type: ".concat((null === (e = this.getMetaStyles()) || void 0 === e ? void 0 : e.button_type) || "plain", "\n                }\n                .apple-pay-button-black {\n                    -apple-pay-button-style: black;\n                }\n                .apple-pay-button-white {\n                    -apple-pay-button-style: white;\n                }\n                .apple-pay-button-white-with-line {\n                    -apple-pay-button-style: white-outline;\n                }\n            }\n\n            @supports not (-webkit-appearance: -apple-pay-button) {\n                .apple-pay-button {\n                    display: inline-block;\n                    background-size: 100% 60%;\n                    background-repeat: no-repeat;\n                    background-position: 50% 50%;\n                    border-radius: 5px;\n                    padding: 0px;\n                    box-sizing: border-box;\n                    min-width: 200px;\n                    min-height: 32px;\n                    max-height: 64px;\n                    -apple-pay-button-type: ").concat((null === (t = this.getMetaStyles()) || void 0 === t ? void 0 : t.button_type) || "plain", "\n                }\n                .apple-pay-button-black {\n                    background-image: -webkit-named-image(apple-pay-logo-white);\n                    background-color: black;\n                }\n                .apple-pay-button-white {\n                    background-image: -webkit-named-image(apple-pay-logo-black);\n                    background-color: white;\n                }\n                .apple-pay-button-white-with-line {\n                    background-image: -webkit-named-image(apple-pay-logo-black);\n                    background-color: white;\n                    border: .5px solid black;\n                }\n            }\n        ")
                }
            }]), o
        }(),
        Vt = function() {
            u(o, Ut);
            var r = h(o);

            function o(e, t, n, i) {
                var u;
                return g(this, o), (u = r.call(this, e, t)).gatewayName = n, u.eventEmitter = i, u.parseUpdateData = function(n) {
                    var e, t, i, r, o, a, s = null === (t = null === (e = u.meta) || void 0 === e ? void 0 : e.shipping_options) || void 0 === t ? void 0 : t.find(function(e) {
                        var t;
                        return e.id === (null === (t = null == n ? void 0 : n.shippingOptionData) || void 0 === t ? void 0 : t.id)
                    });
                    return R({
                        shipping: {
                            address_city: null === (i = n.shippingAddress) || void 0 === i ? void 0 : i.locality,
                            address_state: null === (r = n.shippingAddress) || void 0 === r ? void 0 : r.administrativeArea,
                            address_postcode: null === (o = null == n ? void 0 : n.shippingAddress) || void 0 === o ? void 0 : o.postalCode,
                            address_country: null === (a = null == n ? void 0 : n.shippingAddress) || void 0 === a ? void 0 : a.countryCode
                        }
                    }, s && {
                        selected_shipping_option: {
                            id: null == s ? void 0 : s.id,
                            label: null == s ? void 0 : s.label,
                            detail: null == s ? void 0 : s.detail,
                            type: null == s ? void 0 : s.type
                        }
                    })
                }, u.formatShippingOptions = function(e) {
                    return e.map(function(e) {
                        return {
                            id: e.id,
                            label: e.label,
                            description: (null == e ? void 0 : e.detail) || ""
                        }
                    })
                }, u.eventEmitter = i, u
            }
            return d(o, [{
                key: "getGatewayName",
                value: function() {
                    return this.gatewayName
                }
            }, {
                key: "getMerchantId",
                value: function() {
                    var e, t, n;
                    return null === (n = null === (t = null === (e = this.meta) || void 0 === e ? void 0 : e.credentials) || void 0 === t ? void 0 : t[P.GOOGLE]) || void 0 === n ? void 0 : n.merchant
                }
            }, {
                key: "getMetaStyles",
                value: function() {
                    var e, t, n, i;
                    return "object" === K(null === (e = this.meta) || void 0 === e ? void 0 : e.style) && "google" in (null === (t = this.meta) || void 0 === t ? void 0 : t.style) ? null === (i = null === (n = this.meta) || void 0 === n ? void 0 : n.style) || void 0 === i ? void 0 : i.google : null
                }
            }, {
                key: "getMetaRawDataInitialization",
                value: function() {
                    var e, t, n, i, r;
                    return null !== (e = this.meta) && void 0 !== e && e.raw_data_initialization && "object" === K(null === (t = this.meta) || void 0 === t ? void 0 : t.raw_data_initialization) && "google" in (null === (n = this.meta) || void 0 === n ? void 0 : n.raw_data_initialization) ? null === (r = null === (i = this.meta) || void 0 === i ? void 0 : i.raw_data_initialization) || void 0 === r ? void 0 : r.google : null
                }
            }, {
                key: "isShippingRequired",
                value: function() {
                    return !!this.meta.request_shipping
                }
            }, {
                key: "hasShippingOptions",
                value: function() {
                    return this.meta.request_shipping && !!this.meta.shipping_options
                }
            }, {
                key: "load",
                value: function(a) {
                    var s = this;
                    if (window.Promise) return new Promise(function(r, o) {
                        var e = document.createElement("script");
                        e.type = "text/javascript", e.src = "https://pay.google.com/gp/p/js/pay.js", e.async = !0, e.onload = function() {
                            var e, t, n, i;
                            if (!window.google) return s.eventEmitter.emit(It.UNAVAILABLE, {
                                wallet: P.GOOGLE
                            }), void o();
                            s.isShippingRequired() && s.hasShippingOptions() && (s.selectedShippingOption = null === (e = s.meta) || void 0 === e ? void 0 : e.shipping_options[0]), s.paymentsClient = new google.payments.api.PaymentsClient(R({
                                merchantInfo: R(R({}, null !== (t = s.meta) && void 0 !== t && t.merchant_name ? {
                                    merchantName: null === (n = s.meta) || void 0 === n ? void 0 : n.merchant_name
                                } : {}), {
                                    merchantId: s.getMerchantId()
                                }),
                                paymentDataCallbacks: R({
                                    onPaymentAuthorized: function(e) {
                                        return s.onPaymentAuthorized(e)
                                    }
                                }, s.isShippingRequired() && {
                                    onPaymentDataChanged: function(e) {
                                        return s.onPaymentDataChanged(e)
                                    }
                                })
                            }, "live" === (null === (i = s.meta) || void 0 === i ? void 0 : i.gateway_mode) ? {
                                environment: "PRODUCTION"
                            } : {
                                environment: "TEST"
                            })), s.checkAvailability().then(function(e) {
                                if (!e) return s.eventEmitter.emit(It.UNAVAILABLE, {
                                    wallet: P.GOOGLE
                                }), void o();
                                s.mount(a), r()
                            })
                        }, document.head.appendChild(e)
                    });
                    this.eventEmitter.emit(It.UNAVAILABLE, {
                        wallet: P.GOOGLE
                    })
                }
            }, {
                key: "update",
                value: function(e) {
                    var t, n, i, r;
                    if (this.latestShippingChangePromiseResolve && this.latestShippingChangePromiseReject) {
                        if (!e.success) return this.latestShippingChangePromiseReject();
                        var o = (null === (t = null == e ? void 0 : e.body) || void 0 === t ? void 0 : t.amount) || this.meta.amount,
                            a = null === (n = null == e ? void 0 : e.body) || void 0 === n ? void 0 : n.shipping_options;
                        o && (this.meta.amount = o), a && (this.meta.shipping_options = a, this.selectedShippingOption = a ? a[0] : void 0);
                        var s = R({
                            newTransactionInfo: {
                                totalPriceStatus: "FINAL",
                                totalPriceLabel: this.meta.amount_label,
                                totalPrice: null === (i = this.meta.amount) || void 0 === i ? void 0 : i.toString(),
                                currencyCode: this.meta.currency.toUpperCase(),
                                countryCode: this.meta.country.toUpperCase()
                            }
                        }, this.isShippingRequired() && this.hasShippingOptions() && a && {
                            newShippingOptionParameters: {
                                defaultSelectedOptionId: null === (r = this.selectedShippingOption) || void 0 === r ? void 0 : r.id,
                                shippingOptions: this.formatShippingOptions(this.meta.shipping_options)
                            }
                        });
                        this.latestShippingChangePromiseResolve(s)
                    }
                }
            }, {
                key: "checkAvailability",
                value: function() {
                    return this.paymentsClient.isReadyToPay(this.createRequest()).then(function(e) {
                        return !!e.result
                    }).catch(function(e) {
                        return console.error("Error checking GooglePay availability", e), !1
                    })
                }
            }, {
                key: "mount",
                value: function(e) {
                    var t, n, i, r = this;
                    e.getElement().appendChild(this.paymentsClient.createButton({
                        onClick: function() {
                            return r.loadPaymentData()
                        },
                        buttonType: (null === (t = this.getMetaStyles()) || void 0 === t ? void 0 : t.button_type) || "pay",
                        buttonSizeMode: (null === (n = this.getMetaStyles()) || void 0 === n ? void 0 : n.button_size_mode) || "fill",
                        buttonColor: (null === (i = this.getMetaStyles()) || void 0 === i ? void 0 : i.button_color) || "default"
                    }))
                }
            }, {
                key: "loadPaymentData",
                value: function() {
                    this.paymentsClient.loadPaymentData(this.createPaymentDataRequest()).catch(function() {
                        console.error("Error while loading payment data")
                    })
                }
            }, {
                key: "onPaymentAuthorized",
                value: function(v) {
                    var e, t, n, i, r, o, a, s, u, c, l, d, h, p, f, m = this,
                        y = null === (n = null === (t = null === (e = v.paymentMethodData) || void 0 === e ? void 0 : e.info) || void 0 === t ? void 0 : t.billingAddress) || void 0 === n ? void 0 : n.address1,
                        g = null === (o = null === (r = null === (i = v.paymentMethodData) || void 0 === i ? void 0 : i.info) || void 0 === r ? void 0 : r.billingAddress) || void 0 === o ? void 0 : o.address2,
                        k = null === (a = null == v ? void 0 : v.shippingAddress) || void 0 === a ? void 0 : a.address1,
                        E = null === (s = null == v ? void 0 : v.shippingAddress) || void 0 === s ? void 0 : s.address2,
                        _ = null === (u = this.selectedShippingOption) || void 0 === u ? void 0 : u.type,
                        w = null === (c = null == v ? void 0 : v.shippingAddress) || void 0 === c ? void 0 : c.countryCode,
                        b = null === (l = null == v ? void 0 : v.shippingAddress) || void 0 === l ? void 0 : l.locality,
                        C = null === (d = null == v ? void 0 : v.shippingAddress) || void 0 === d ? void 0 : d.postalCode,
                        S = null === (h = null == v ? void 0 : v.shippingAddress) || void 0 === h ? void 0 : h.administrativeArea,
                        T = null === (p = null == v ? void 0 : v.shippingAddress) || void 0 === p ? void 0 : p.name,
                        O = null == v ? void 0 : v.email,
                        A = null === (f = null == v ? void 0 : v.shippingAddress) || void 0 === f ? void 0 : f.phoneNumber;
                    return new Promise(function(t) {
                        var e, n, i, r, o, a, s, u, c, l, d, h, p, f;
                        return m.eventEmitter.emit(It.PAYMENT_METHOD_SELECTED, {
                            data: R({
                                customer: {
                                    payment_source: R(R(R(R({
                                        wallet_type: P.GOOGLE,
                                        type: v.paymentMethodData.type,
                                        card_scheme: null === (n = null === (e = v.paymentMethodData) || void 0 === e ? void 0 : e.info) || void 0 === n ? void 0 : n.cardNetwork
                                    }, y && {
                                        address_line1: y
                                    }), g && {
                                        address_line2: g
                                    }), g && {
                                        address_line2: g
                                    }), {
                                        address_country: null === (o = null === (r = null === (i = v.paymentMethodData) || void 0 === i ? void 0 : i.info) || void 0 === r ? void 0 : r.billingAddress) || void 0 === o ? void 0 : o.countryCode,
                                        address_city: null === (u = null === (s = null === (a = v.paymentMethodData) || void 0 === a ? void 0 : a.info) || void 0 === s ? void 0 : s.billingAddress) || void 0 === u ? void 0 : u.locality,
                                        address_postcode: null === (d = null === (l = null === (c = v.paymentMethodData) || void 0 === c ? void 0 : c.info) || void 0 === l ? void 0 : l.billingAddress) || void 0 === d ? void 0 : d.postalCode,
                                        address_state: null === (f = null === (p = null === (h = v.paymentMethodData) || void 0 === h ? void 0 : h.info) || void 0 === p ? void 0 : p.billingAddress) || void 0 === f ? void 0 : f.administrativeArea,
                                        ref_token: v.paymentMethodData.tokenizationData.token
                                    })
                                }
                            }, m.isShippingRequired() && {
                                shipping: R(R(R(R(R(R(R(R(R({}, _ && {
                                    method: _
                                }), m.hasShippingOptions() && {
                                    options: m.meta.shipping_options
                                }), k && {
                                    address_line1: k
                                }), E && {
                                    address_line2: E
                                }), w && {
                                    address_country: w
                                }), b && {
                                    address_city: b
                                }), C && {
                                    address_postcode: C
                                }), S && {
                                    address_state: S
                                }), {
                                    contact: R(R(R({}, T && {
                                        first_name: T
                                    }), O && {
                                        email: O
                                    }), A && {
                                        phone: A
                                    })
                                })
                            }),
                            onSuccess: function() {
                                return t({
                                    transactionState: "SUCCESS"
                                })
                            },
                            onError: function(e) {
                                return t({
                                    transactionState: "ERROR",
                                    error: {
                                        intent: "PAYMENT_AUTHORIZATION",
                                        message: (null == e ? void 0 : e.message) || "Error processing payment",
                                        reason: "PAYMENT_DATA_INVALID"
                                    }
                                })
                            }
                        })
                    })
                }
            }, {
                key: "onPaymentDataChanged",
                value: function(e) {
                    var n = this;
                    if (this.isShippingRequired()) {
                        var t = this.parseUpdateData(e),
                            i = new Promise(function(e, t) {
                                n.latestShippingChangePromiseResolve = e, n.latestShippingChangePromiseReject = t
                            });
                        return this.eventEmitter.emit(It.UPDATE, t), i
                    }
                }
            }, {
                key: "createRequest",
                value: function() {
                    var e = "Apple Safari" === Je.getBrowserName();
                    return {
                        apiVersion: 2,
                        apiVersionMinor: 0,
                        allowedPaymentMethods: [this.createCardData()],
                        existingPaymentMethodRequired: !e
                    }
                }
            }, {
                key: "createPaymentDataRequest",
                value: function() {
                    var e, t, n, i;
                    this.isShippingRequired() && this.hasShippingOptions() && (this.selectedShippingOption = null === (e = this.meta) || void 0 === e ? void 0 : e.shipping_options[0]);
                    var r = this.getMerchantId();
                    return R({
                        apiVersion: 2,
                        apiVersionMinor: 0,
                        allowedPaymentMethods: [R(R({}, this.createCardData()), {
                            tokenizationSpecification: {
                                type: "PAYMENT_GATEWAY",
                                parameters: {
                                    gateway: "paydock",
                                    gatewayMerchantId: r
                                }
                            }
                        })],
                        transactionInfo: {
                            totalPriceStatus: "FINAL",
                            totalPriceLabel: this.meta.amount_label,
                            totalPrice: this.meta.amount.toString(),
                            currencyCode: this.meta.currency.toUpperCase(),
                            countryCode: this.meta.country.toUpperCase()
                        },
                        merchantInfo: R(R({}, null !== (t = this.meta) && void 0 !== t && t.merchant_name ? {
                            merchantName: null === (n = this.meta) || void 0 === n ? void 0 : n.merchant_name
                        } : {}), {
                            merchantId: r
                        }),
                        callbackIntents: ["PAYMENT_AUTHORIZATION"].concat(s(this.isShippingRequired() ? ["SHIPPING_ADDRESS"] : []), s(this.hasShippingOptions() ? ["SHIPPING_OPTION"] : []))
                    }, this.isShippingRequired() && R({
                        shippingAddressRequired: !0
                    }, this.hasShippingOptions() && {
                        shippingOptionRequired: !0,
                        shippingOptionParameters: {
                            defaultSelectedOptionId: null === (i = this.selectedShippingOption) || void 0 === i ? void 0 : i.id,
                            shippingOptions: this.formatShippingOptions(this.meta.shipping_options)
                        }
                    }))
                }
            }, {
                key: "createCardData",
                value: function() {
                    return this.getMetaRawDataInitialization() || {
                        type: "CARD",
                        parameters: {
                            allowedAuthMethods: ["PAN_ONLY", "CRYPTOGRAM_3DS"],
                            allowedCardNetworks: ["AMEX", "DISCOVER", "INTERAC", "JCB", "MASTERCARD", "VISA"],
                            billingAddressRequired: !!this.meta.show_billing_address
                        }
                    }
                }
            }]), o
        }(),
        Wt = function() {
            u(t, Ut);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "initializeChildWallets",
                value: function() {
                    var e, t, n, i, r, o;
                    this.childWallets = [];
                    var a = !(null === (n = null === (t = null === (e = this.meta) || void 0 === e ? void 0 : e.credentials) || void 0 === t ? void 0 : t.apple) || void 0 === n || !n.merchant),
                        s = !(null === (o = null === (r = null === (i = this.meta) || void 0 === i ? void 0 : i.credentials) || void 0 === r ? void 0 : r.google) || void 0 === o || !o.merchant);
                    !a || this.meta.wallets && !this.meta.wallets.includes(P.APPLE) || this.childWallets.push(new Yt(this.publicKey, this.meta, this.getGatewayName(), this.eventEmitter)), !s || this.meta.wallets && !this.meta.wallets.includes(P.GOOGLE) || this.childWallets.push(new Vt(this.publicKey, this.meta, this.getGatewayName(), this.eventEmitter))
                }
            }, {
                key: "getGatewayName",
                value: function() {
                    return b.MASTERCARD
                }
            }, {
                key: "setEnv",
                value: function(t) {
                    return this.childWallets.forEach(function(e) {
                        return e.setEnv(t)
                    }), this
                }
            }, {
                key: "update",
                value: function(t) {
                    this.childWallets.forEach(function(e) {
                        return e.update(t)
                    })
                }
            }]), t
        }();
    (Ht = Ft = Ft || {})[Ht.PUBLIC_KEY = 0] = "PUBLIC_KEY", Ht[Ht.TOKEN = 1] = "TOKEN";
    var Kt, Gt, Jt = function() {
            function n(e, t) {
                g(this, n), this.auth = e, this.authType = t || this.setAuthType(), this.env = new re($)
            }
            return d(n, [{
                key: "setEnv",
                value: function(e, t) {
                    return this.env.setEnv(e, t), this
                }
            }, {
                key: "setAuthType",
                value: function() {
                    return this.authType = _.validateJWT(this.auth) ? Ft.TOKEN : Ft.PUBLIC_KEY
                }
            }, {
                key: "getClient",
                value: function(e, t) {
                    var i = this,
                        r = new XMLHttpRequest;
                    return r.open(e, this.env.getConf().url + t, !0), r.setRequestHeader("Content-Type", "application/json; charset=UTF-8"), this.setAuthHeader(r), w.version && (r.setRequestHeader(w.headerKeys.version, w.version), r.setRequestHeader(w.headerKeys.type, w.type)), {
                        config: r,
                        send: function(e, t, n) {
                            r.onload = function() {
                                return i.parser({
                                    text: r.responseText,
                                    status: r.status
                                }, t, n)
                            }, r.send(JSON.stringify(e))
                        }
                    }
                }
            }, {
                key: "getClientPromise",
                value: function(e, t) {
                    var i = this,
                        r = new XMLHttpRequest;
                    return r.open(e, this.env.getConf().url + t, !0), r.setRequestHeader("Content-Type", "application/json; charset=UTF-8"), this.setAuthHeader(r), w.version && (r.setRequestHeader(w.headerKeys.version, w.version), r.setRequestHeader(w.headerKeys.type, w.type)), {
                        config: r,
                        send: function(n) {
                            return new Promise(function(e, t) {
                                r.onload = function() {
                                    return e({
                                        text: r.responseText,
                                        status: r.status
                                    })
                                }, r.send(JSON.stringify(n))
                            }).then(function(e) {
                                return i.parserPromise(e)
                            })
                        }
                    }
                }
            }, {
                key: "parser",
                value: function(e, t, n) {
                    var i = e.text,
                        r = e.status;
                    try {
                        var o = JSON.parse(i);
                        if (200 <= r && r < 300 || 302 === r) return t(o.resource.data);
                        n(o.error || {
                            message: "unknown error"
                        })
                    } catch (e) {}
                }
            }, {
                key: "parserPromise",
                value: function(e) {
                    var t = e.text,
                        n = e.status;
                    try {
                        var i = JSON.parse(t);
                        return 200 <= n && n < 300 || 302 === n ? Promise.resolve(i.resource.data) : Promise.reject(i.error || {
                            message: "unknown error"
                        })
                    } catch (e) {
                        return Promise.reject(e)
                    }
                }
            }, {
                key: "setAuthHeader",
                value: function(e) {
                    switch (this.authType) {
                        case Ft.PUBLIC_KEY:
                            e.setRequestHeader("x-user-public-key", this.auth);
                            break;
                        case Ft.TOKEN:
                            e.setRequestHeader("x-access-token", this.auth)
                    }
                }
            }]), n
        }(),
        Xt = function() {
            function t(e) {
                g(this, t), this.api = e
            }
            return d(t, [{
                key: "walletCapture",
                value: function(e) {
                    return this.api.getClientPromise("POST", "/v1/charges/wallet/capture").send(e)
                }
            }, {
                key: "walletCallback",
                value: function(e) {
                    return this.api.getClientPromise("POST", "/v1/charges/wallet/callback").send(e)
                }
            }, {
                key: "standalone3dsProcess",
                value: function(e) {
                    return this.api.getClientPromise("POST", "/v1/charges/standalone-3ds/process").send(e)
                }
            }, {
                key: "standalone3dsHandle",
                value: function() {
                    return this.api.getClientPromise("GET", "/v1/charges/standalone-3ds/handle").send(void 0)
                }
            }]), t
        }(),
        Zt = function() {
            function t(e) {
                g(this, t), this.api = e
            }
            return d(t, [{
                key: "getConfig",
                value: function(e) {
                    var t = "/v1/services/:service_id/config".replace(":service_id", e);
                    return this.api.getClientPromise("GET", t).send(void 0)
                }
            }]), t
        }();
    (Gt = Kt = Kt || {}).VISA_SRC = "VisaSRC", Gt.MASTERCARD_SRC = "MastercardSRCClickToPay";
    var Qt = function() {
            u(t, Jt);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "charge",
                value: function() {
                    return new Xt(this)
                }
            }, {
                key: "service",
                value: function() {
                    return new Zt(this)
                }
            }]), t
        }(),
        $t = function() {
            u(r, Ut);
            var i = h(r);

            function r(e, t) {
                var n;
                return g(this, r), (n = i.call(this, e, t)).token = e, n.storageDispatcher = new gt("afterpay.wallet.paydock"), n
            }
            return d(r, [{
                key: "load",
                value: function(e) {
                    var t = this;
                    this.storageDispatcher.create(function() {
                        return t.mount(e)
                    })
                }
            }, {
                key: "setEnv",
                value: function(e) {
                    return l(c(r.prototype), "setEnv", this).call(this, e), this.storageDispatcher.setEnv(e), this
                }
            }, {
                key: "mount",
                value: function(e) {
                    var t, n, i, r, o = this,
                        a = {};
                    null !== (t = this.meta) && void 0 !== t && t.style && "object" === K(null === (n = this.meta) || void 0 === n ? void 0 : n.style) && (a = JSON.parse(JSON.stringify((null === (i = this.meta) || void 0 === i ? void 0 : i.style.afterpay) || (null === (r = this.meta) || void 0 === r ? void 0 : r.style))));
                    var s = this.getButton(a);
                    s.onclick = function() {
                        return o.onAfterPayButtonClicked()
                    };
                    var u = this.getButtonStyle(a);
                    e.getElement().appendChild(s), e.getElement().appendChild(u)
                }
            }, {
                key: "onAfterPayButtonClicked",
                value: function() {
                    var e, t, n = this,
                        i = document.createElement("script"),
                        r = null === (e = this.meta) || void 0 === e ? void 0 : e.country;
                    i.type = "text/javascript", i.src = "live" === (null === (t = this.meta) || void 0 === t ? void 0 : t.gateway_mode) ? "https://portal.afterpay.com/afterpay.js" : "https://portal.sandbox.afterpay.com/afterpay.js", i.async = !0, i.defer = !0, i.onload = function() {
                        window.AfterPay.initialize({
                            countryCode: r
                        }), n.storageDispatcher.push({
                            intent: ht.WIDGET_SESSION,
                            data: {
                                token: n.token
                            }
                        }, {
                            onSuccess: function() {
                                n.getCheckoutSession().then(function(e) {
                                    window.AfterPay.redirect({
                                        token: e.ref_token
                                    })
                                }).catch(function(e) {
                                    window.AfterPay.close(), n.eventEmitter.emit(It.UNAVAILABLE, {
                                        err: e
                                    })
                                })
                            },
                            onError: function() {
                                console.error("Error initializing Afterpay wallet"), window.AfterPay.close(), n.eventEmitter.emit(It.UNAVAILABLE, {})
                            }
                        })
                    }, document.head.appendChild(i)
                }
            }, {
                key: "getCheckoutSession",
                value: function() {
                    var e = this;
                    return new Promise(function(t, n) {
                        return e.eventEmitter.emit(It.CALLBACK, {
                            data: {
                                request_type: "CREATE_SESSION",
                                wallet_type: P.AFTERPAY
                            },
                            onSuccess: function(e) {
                                t(e)
                            },
                            onError: function(e) {
                                n(e)
                            }
                        })
                    })
                }
            }, {
                key: "getButton",
                value: function(e) {
                    var t = document.createElement("button");
                    return t.classList.add("afterpay-checkout-btn"), t.setAttribute("type", "button"), t.innerHTML = '\n            <div class="afterpay-checkout-btn__wrapper">\n                <svg viewBox="0 0 390 94"\n                    height="'.concat(this.getHeight(e), '"\n                    xmlns="http://www.w3.org/2000/svg">\n                    <g fill="currentColor">\n                        <path\n                            d="M388.6 21.4l-34.8 71.8h-14.4l13-26.8-20.5-45h14.8l13.2 30.1 14.3-30.1zM41 46.9c0-8.6-6.2-14.6-13.9-14.6s-13.9 6.1-13.9 14.6c0 8.4 6.2 14.6 13.9 14.6 7.6 0 13.9-6.1 13.9-14.6m.1 25.5v-6.6c-3.8 4.6-9.4 7.4-16.1 7.4C11 73.2.4 62 .4 46.9c0-15 11-26.4 24.9-26.4 6.5 0 12 2.9 15.8 7.3v-6.4h12.5v51H41.1zM114.6 61.1c-4.4 0-5.6-1.6-5.6-5.9V32.5h8.1V21.4H109V8.9H96.1v12.4H79.5v-5.1c0-4.3 1.6-5.9 6.1-5.9h2.8V.4h-6.2C71.6.4 66.6 3.9 66.6 14.5v6.8h-7.1v11.1h7.1v39.9h12.9V32.5h16.6v25c0 10.4 4 14.9 14.4 14.9h6.6V61.1h-2.5zM160.7 42.3c-.9-6.6-6.3-10.6-12.6-10.6s-11.5 3.9-12.9 10.6h25.5zm-25.6 7.9c.9 7.5 6.3 11.8 13.2 11.8 5.4 0 9.6-2.6 12-6.6h13.2c-3.1 10.8-12.7 17.7-25.5 17.7-15.4 0-26.2-10.8-26.2-26.2 0-15.4 11.4-26.5 26.5-26.5 15.2 0 26.2 11.2 26.2 26.5 0 1.1-.1 2.2-.3 3.3h-39.1zM256.2 46.9c0-8.3-6.2-14.6-13.9-14.6s-13.9 6.1-13.9 14.6c0 8.4 6.2 14.6 13.9 14.6 7.6 0 13.9-6.4 13.9-14.6m-40.4 46.3V21.4h12.5V28c3.8-4.7 9.4-7.5 16.1-7.5 13.8 0 24.6 11.3 24.6 26.3s-11 26.4-24.9 26.4c-6.4 0-11.7-2.6-15.4-6.8v26.8h-12.9zM314.2 46.9c0-8.6-6.2-14.6-13.9-14.6-7.6 0-13.9 6.1-13.9 14.6 0 8.4 6.2 14.6 13.9 14.6s13.9-6.1 13.9-14.6m.1 25.5v-6.6c-3.8 4.6-9.4 7.4-16.1 7.4-14 0-24.6-11.2-24.6-26.3 0-15 11-26.4 24.9-26.4 6.5 0 12 2.9 15.8 7.3v-6.4h12.5v51h-12.5zM193.2 26.4s3.2-5.9 11-5.9c3.3 0 5.5 1.2 5.5 1.2v13s-4.7-2.9-9.1-2.3c-4.3.6-7.1 4.6-7.1 9.9v30.2h-13v-51H193v4.9h.2z" />\n                    </g>\n                </svg>\n                <svg viewBox="0 0 107 96"\n                    height="').concat(this.getHeight(e), '"\n                    xmlns="http://www.w3.org/2000/svg">\n                    <path\n                        d="M99 19.5L84.2 11l-15-8.6c-10-5.7-22.4 1.5-22.4 13v1.9c0 1.1.6 2 1.5 2.6l7 4c1.9 1.1 4.4-.3 4.4-2.5v-4.6c0-2.3 2.5-3.7 4.4-2.6l13.8 7.9L91.6 30c2 1.1 2 4 0 5.1L77.9 43l-13.8 7.9c-2 1.1-4.4-.3-4.4-2.6V46c0-11.5-12.4-18.7-22.4-13l-15 8.6-14.8 8.5c-10 5.7-10 20.2 0 26l14.8 8.5 15 8.6c10 5.7 22.4-1.5 22.4-13v-1.9c0-1.1-.6-2-1.5-2.6l-7-4c-1.9-1.1-4.4.3-4.4 2.5v4.6c0 2.3-2.5 3.7-4.4 2.6l-13.8-7.9-13.7-7.9c-2-1.1-2-4 0-5.1l13.7-7.9 13.8-7.9c2-1.1 4.4.3 4.4 2.6v2.3c0 11.5 12.4 18.7 22.4 13l15-8.6L99 45.5c10.1-5.8 10.1-20.2 0-26"\n                        fill="currentColor" />\n                </svg>\n            </div>\n        '), t
                }
            }, {
                key: "getButtonStyle",
                value: function(e) {
                    var t = document.createElement("style"),
                        n = this.generateButtonColor(e.button_type);
                    return t.innerText = "\n            .afterpay-checkout-btn {\n                outline: none;\n                border: none;\n                border-radius: ".concat(this.getHeight(e), ";\n                padding: 0;\n                margin: 0;\n                transition: all 300ms;\n                cursor: pointer;\n            }\n\n            .afterpay-checkout-btn:active {\n                opacity: 0.7;\n            }\n\n            .afterpay-checkout-btn__wrapper {\n                display: flex;\n                align-items: center;\n                padding: 10px 20px;\n                color: ").concat(n.color, ";\n                background-color: ").concat(n.background, ";\n                border-radius: ").concat(this.getHeight(e), ";\n            }\n        "), t
                }
            }, {
                key: "generateButtonColor",
                value: function(e) {
                    switch (e) {
                        case "black":
                            return {
                                color: "#B2FCE3", background: "#000"
                            };
                        case "mint":
                            return {
                                color: "#000", background: "#B2FCE3"
                            };
                        default:
                            return {
                                color: "#fff", background: "#000"
                            }
                    }
                }
            }, {
                key: "getHeight",
                value: function(e) {
                    return e.height ? Number.isNaN(Number(e.height)) ? e.height : "".concat(e.height, "px") : "40px"
                }
            }]), r
        }();
    var en, tn, nn = function() {
            function m(e) {
                var t, n = this,
                    i = e.auth,
                    r = e.url,
                    o = e.clientId,
                    a = e.mode,
                    s = e.orderId,
                    u = e.onCheckoutClosed,
                    c = e.onError,
                    l = e.onTokensChanged,
                    d = e.onPaymentSuccess,
                    h = e.onPaymentError,
                    p = e.title,
                    f = e.windowFeatures;
                g(this, m), k(this, "DEFAULT_WIDTH", 450), k(this, "DEFAULT_HEIGHT", 750), k(this, "DEFAULT_FEATURES", {
                    resizable: "no"
                }), k(this, "auth", void 0), k(this, "callback", void 0), k(this, "error", void 0), k(this, "frame", void 0), k(this, "isCheckoutOpen", void 0), k(this, "onMessage", void 0), k(this, "url", void 0), k(this, "orderId", void 0), k(this, "accessToken", void 0), k(this, "refreshToken", void 0), k(this, "clientId", void 0), k(this, "onCheckoutClosed", void 0), k(this, "rootUrl", void 0), k(this, "targetOrigin", void 0), k(this, "title", void 0), k(this, "windowFeatures", void 0), k(this, "windowObserver", void 0), k(this, "open", function() {
                    var e;
                    n.isCheckoutOpen ? null === (e = n.frame) || void 0 === e || e.focus() : (n.frame = window.open(n.url, n.title, n.getFeatures()), n.isCheckoutOpen = !0, n.startWindowObserver())
                }), k(this, "close", function() {
                    n.frame = void 0, n.isCheckoutOpen = !1, n.stopWindowObserver()
                }), k(this, "listenMessage", function() {
                    n.onMessage && window.addEventListener("message", n.onMessage, !1)
                }), k(this, "postMessage", function() {
                    n.frame && n.rootUrl && n.frame.postMessage({
                        auth: y({}, n.auth)
                    }, n.rootUrl)
                }), this.callback = (k(t = {}, "ERROR", function(e) {
                    var t = e.error,
                        n = e.orderId;
                    null == c || c({
                        error: t,
                        orderId: n
                    })
                }), k(t, "PAYMENT_ERROR", function(e) {
                    var t = e.error,
                        n = e.orderId;
                    null == h || h({
                        error: t,
                        orderId: n
                    })
                }), k(t, "PAYMENT_SUCCESS", function(e) {
                    var t = e.orderId;
                    null == d || d({
                        orderId: t
                    })
                }), k(t, "TOKENS_CHANGED", function(e) {
                    var t = e.accessToken,
                        n = e.refreshToken;
                    null == l || l({
                        accessToken: t,
                        refreshToken: n
                    })
                }), t), this.auth = i, this.isCheckoutOpen = !1, this.error = void 0, this.frame = void 0, this.onMessage = function(e) {
                    var t = e.data;
                    e.origin === r && (!0 === (null == t ? void 0 : t.isDomReady) && n.postMessage(), null != t && t.isPaymentSuccessful && n.callback.PAYMENT_SUCCESS({
                        orderId: t.orderId
                    }), null != t && t.isPaymentSuccessful || null == t || !t.error || n.callback.PAYMENT_ERROR({
                        orderId: t.orderId,
                        error: t.error
                    }), null != t && t.paymentFlowState || null == t || !t.error || n.callback.ERROR({
                        orderId: t.orderId,
                        error: t.error
                    }), null != t && t.accessToken && null != t && t.refreshToken && n.callback.TOKENS_CHANGED({
                        accessToken: t.accessToken,
                        refreshToken: t.refreshToken
                    }))
                };
                var v = a || "default";
                this.rootUrl = r, this.targetOrigin = window.location.href.replace(/\/$/, ""), this.url = "".concat(r, "?orderId=").concat(s, "&merchantUrl=").concat(encodeURIComponent(this.targetOrigin), "&mode=").concat(v), this.orderId = s, this.clientId = o, this.onCheckoutClosed = u, this.title = p, this.windowFeatures = f, this.windowObserver = void 0
            }
            return d(m, [{
                key: "isWindowObserverOpen",
                get: function() {
                    return !!this.windowObserver
                }
            }, {
                key: "getFeatures",
                value: function() {
                    var e, t, n = (null === (e = this.windowFeatures) || void 0 === e ? void 0 : e.width) || this.DEFAULT_WIDTH,
                        i = (null === (t = this.windowFeatures) || void 0 === t ? void 0 : t.height) || this.DEFAULT_HEIGHT,
                        r = y(y({}, this.DEFAULT_FEATURES), this.windowFeatures);
                    return function(e, t) {
                        var o = 1 < arguments.length && void 0 !== t ? t : "=";
                        return Object.keys(e).length ? Object.entries(e).reduce(function(e, t) {
                            var n = a(t, 2),
                                i = n[0],
                                r = n[1];
                            return [].concat(s(e), ["".concat(i).concat(o).concat(r)])
                        }, []).join(",") : ""
                    }(y(y(y({}, this.getCenteredPosition(n, i)), r), {}, {
                        width: n,
                        height: i
                    }))
                }
            }, {
                key: "getCenteredPosition",
                value: function(e, t) {
                    return {
                        left: screen.width / 2 - e / 2,
                        top: screen.height / 2 - t / 2
                    }
                }
            }, {
                key: "startWindowObserver",
                value: function() {
                    var n = this;
                    this.isWindowObserverOpen || (this.windowObserver = setInterval(function() {
                        var e, t;
                        null !== (e = n.frame) && void 0 !== e && e.closed && (n.close(), null === (t = n.onCheckoutClosed) || void 0 === t || t.call(n, {
                            orderId: n.orderId
                        }), n.onMessage && window.removeEventListener("message", n.onMessage))
                    }, 300))
                }
            }, {
                key: "stopWindowObserver",
                value: function() {
                    clearInterval(this.windowObserver)
                }
            }]), m
        }(),
        rn = function(e, a, s, u) {
            return new(s = s || Promise)(function(n, t) {
                function i(e) {
                    try {
                        o(u.next(e))
                    } catch (e) {
                        t(e)
                    }
                }

                function r(e) {
                    try {
                        o(u.throw(e))
                    } catch (e) {
                        t(e)
                    }
                }

                function o(e) {
                    var t;
                    e.done ? n(e.value) : ((t = e.value) instanceof s ? t : new s(function(e) {
                        e(t)
                    })).then(i, r)
                }
                o((u = u.apply(e, a || [])).next())
            })
        },
        on = function() {
            u(r, Ut);
            var i = h(r);

            function r(e, t) {
                var n;
                return g(this, r), (n = i.call(this, e, t)).onFlypayV2ButtonClick = function() {
                    return rn(o(n), void 0, void 0, x().mark(function e() {
                        var t, n;
                        return x().wrap(function(e) {
                            for (;;) switch (e.prev = e.next) {
                                case 0:
                                    if (t = document.getElementById("loading-overlay"), (n = document.getElementById("flypay-v2-button")) && (n.disabled = !0), e.prev = 3, this.orderId) {
                                        e.next = 9;
                                        break
                                    }
                                    return t && (t.style.display = "flex"), e.next = 8, this.getOrderId();
                                case 8:
                                    this.orderId = e.sent;
                                case 9:
                                    t && (t.style.display = "none"), this.orderId ? this.flypayV2Checkout(this.orderId) : this.eventEmitter.emit(It.UNAVAILABLE), e.next = 18;
                                    break;
                                case 13:
                                    e.prev = 13, e.t0 = e.catch(3), t && (t.style.display = "none"), n && (n.disabled = !1), this.eventEmitter.emit(It.UNAVAILABLE, {
                                        err: e.t0
                                    });
                                case 18:
                                case "end":
                                    return e.stop()
                            }
                        }, e, this, [
                            [3, 13]
                        ])
                    }))
                }, n.accessToken = null == t ? void 0 : t.access_token, n.refreshToken = null == t ? void 0 : t.refresh_token, n.link = new ue(""), n
            }
            return d(r, [{
                key: "load",
                value: function(e) {
                    this.mount(e)
                }
            }, {
                key: "setEnv",
                value: function(e) {
                    return this.link.setEnv(e), l(c(r.prototype), "setEnv", this).call(this, e)
                }
            }, {
                key: "mount",
                value: function(e) {
                    var t = this.getButton();
                    t.onclick = this.onFlypayV2ButtonClick, e.getElement().appendChild(t)
                }
            }, {
                key: "getButton",
                value: function() {
                    var e = document.createElement("style");
                    e.innerHTML = this.createButtonStyle(), document.head.appendChild(e);
                    var t = document.createElement("button");
                    return t.classList.add("flypay-v2-checkout-btn"), t.setAttribute("type", "button"), t.setAttribute("id", "flypay-v2-button"), t.innerHTML = '\n        <div id="loading-overlay"></div>\n        <div class="flypay-v2-checkout-btn__wrapper">\n            <img src="'.concat(this.link.getBaseUrl(), '/images/flypay-checkout.png" alt="Flypay Checkout" class="flypay-v2-image">\n        </div>\n    '), t
                }
            }, {
                key: "createButtonStyle",
                value: function() {
                    return '\n\t\t\t#widget {\n\t\t\t\tposition: relative;\n\t\t\t}\n\n\t\t\t#loading-overlay {\n\t\t\t\tposition: absolute;\n\t\t\t\twidth: 268px;\n\t\t\t\theight: 74px;\n\t\t\t\tbackground: rgba(255, 255, 255, 0.7);\n\t\t\t\tdisplay: none;\n\t\t\t\tjustify-content: center;\n\t\t\t\talign-items: center;\n\t\t\t}\n\n\t\t\t#loading-overlay::after {\n\t\t\t\tcontent: "";\n\t\t\t\tdisplay: inline-block;\n\t\t\t\twidth: 40px;\n\t\t\t\theight: 40px;\n\t\t\t\tborder: 4px solid #ccc;\n\t\t\t\tborder-top-color: #333;\n\t\t\t\tborder-radius: 50%;\n\n\t\t\t\t/* Vendor prefixes for animation property */\n\t\t\t\t-webkit-animation: spin 1s infinite linear;\n\t\t\t\t-moz-animation: spin 1s infinite linear;\n\t\t\t\t-o-animation: spin 1s infinite linear;\n\t\t\t\tanimation: spin 1s infinite linear;\n\t\t\t}\n\n\t\t\t@-webkit-keyframes spin {\n\t\t\t\t0% {\n\t\t\t\t-webkit-transform: rotate(0deg);\n\t\t\t\ttransform: rotate(0deg);\n\t\t\t\t}\n\t\t\t\t100% {\n\t\t\t\t-webkit-transform: rotate(360deg);\n\t\t\t\ttransform: rotate(360deg);\n\t\t\t\t}\n\t\t\t}\n\n\t\t\t@-moz-keyframes spin {\n\t\t\t\t0% {\n\t\t\t\t-moz-transform: rotate(0deg);\n\t\t\t\ttransform: rotate(0deg);\n\t\t\t\t}\n\t\t\t\t100% {\n\t\t\t\t-moz-transform: rotate(360deg);\n\t\t\t\ttransform: rotate(360deg);\n\t\t\t\t}\n\t\t\t}\n\n\t\t\t@-o-keyframes spin {\n\t\t\t\t0% {\n\t\t\t\t-o-transform: rotate(0deg);\n\t\t\t\ttransform: rotate(0deg);\n\t\t\t\t}\n\t\t\t\t100% {\n\t\t\t\t-o-transform: rotate(360deg);\n\t\t\t\ttransform: rotate(360deg);\n\t\t\t\t}\n\t\t\t}\n\n\t\t\t@keyframes spin {\n\t\t\t\t0% {\n\t\t\t\ttransform: rotate(0deg);\n\t\t\t\t}\n\t\t\t\t100% {\n\t\t\t\ttransform: rotate(360deg);\n\t\t\t\t}\n\t\t\t}\n\n\t\t\t.flypay-v2-checkout-btn {\n\t\t\t\tborder: none; /* Remove borders */\n\t\t\t\tbackground: transparent; /* Make the button background transparent */\n\t\t\t\tcursor: pointer; /* Make it look clickable */\n\t\t\t\toutline: none; /* Remove focus outline */\n\t\t\t\tpadding: 0; /* Remove any default padding */\n\t\t\t}\n\n\t\t\t.flypay-v2-image {\n\t\t\t\tdisplay: block; /* Display the image as block to remove any gaps */\n\t\t\t\tborder: none; /* Ensure the image doesn\'t have a border */\n\t\t\t\twidth: 100%; /* Make the image take full width of the container */\n\t\t\t}\n\t\t'
                }
            }, {
                key: "getOrderId",
                value: function() {
                    var e = this;
                    return new Promise(function(t, n) {
                        return e.eventEmitter.emit(It.CALLBACK, {
                            data: {
                                request_type: "CREATE_SESSION"
                            },
                            onSuccess: function(e) {
                                return t(e.id)
                            },
                            onError: function(e) {
                                return n(e.error)
                            }
                        })
                    })
                }
            }, {
                key: "flypayV2Checkout",
                value: function(e) {
                    var t, n, i = this;
                    this.checkout = new nn(R(R({
                        orderId: e
                    }, (this.accessToken || this.refreshToken) && {
                        auth: R(R({}, this.accessToken && {
                            access_token: this.accessToken
                        }), this.refreshToken && {
                            refresh_token: this.refreshToken
                        }),
                        mode: "express"
                    }), {
                        clientId: "live" === (null === (t = this.meta) || void 0 === t ? void 0 : t.gateway_mode) ? "dbbd114e-3583-4db5-915e-59f1b3dcd08b" : "924ac1ce-00f4-44e4-8277-06cae751ef1a",
                        url: "live" === (null === (n = this.meta) || void 0 === n ? void 0 : n.gateway_mode) ? "https://checkout.beem.com.au" : "https://release.checkout.beem.com.au",
                        onCheckoutClosed: function() {
                            var e = document.getElementById("flypay-v2-button");
                            e && (e.disabled = !1)
                        },
                        onError: function(e) {
                            return i.eventEmitter.emit(It.PAYMENT_ERROR, {
                                error: e
                            })
                        },
                        onPaymentSuccess: function(e) {
                            return i.eventEmitter.emit(It.PAYMENT_SUCCESS, e)
                        },
                        onPaymentError: function(e) {
                            return i.eventEmitter.emit(It.PAYMENT_ERROR, {
                                error: e
                            })
                        },
                        onTokensChanged: function(e) {
                            var t = e.accessToken,
                                n = e.refreshToken;
                            i.accessToken = t, i.refreshToken = n, i.eventEmitter.emit(It.AUTH_TOKENS_CHANGED, {
                                accessToken: t,
                                refreshToken: n
                            })
                        }
                    })), this.checkout.open(), this.checkout.listenMessage()
                }
            }]), r
        }(),
        an = "unavailable",
        sn = "update",
        un = "paymentSuccessful",
        cn = "paymentError",
        ln = "paymentInReview",
        dn = "authTokensChanged",
        hn = function() {
            function o(e, t, n) {
                g(this, o), this.hasUpdateHandler = !1;
                var i = _.validateJWT(t);
                if (!i) throw new Error("Invalid charge token");
                this.eventEmitter = new We, this.container = new Pe(e);
                var r = _.extractMeta(i.body);
                switch (this.api = new Qt(t, Ft.TOKEN), r.gateway.type) {
                    case b.STRIPE:
                        this.service = new qt(r.credentials.client_auth, R(R({}, n), {
                            amount: r.charge.amount,
                            currency: r.charge.currency
                        }));
                        break;
                    case b.FLYPAY:
                        this.service = new Dt(t, R(R({}, n), {
                            id: r.charge.id,
                            gateway_mode: r.gateway.mode,
                            amount: r.charge.amount,
                            currency: r.charge.currency,
                            reference: r.charge.reference
                        }));
                        break;
                    case b.FLYPAY_V2:
                        this.service = new on(t, R(R({}, n), {
                            id: r.charge.id,
                            gateway_mode: r.gateway.mode,
                            amount: r.charge.amount,
                            currency: r.charge.currency,
                            reference: r.charge.reference
                        }));
                        break;
                    case b.PAYPAL:
                        this.service = new Nt(r.credentials.client_auth, R(R({}, n), {
                            id: r.charge.id,
                            gateway_mode: r.gateway.mode,
                            amount: r.charge.amount,
                            currency: r.charge.currency,
                            capture: r.charge.capture
                        }));
                        break;
                    case b.MASTERCARD:
                        this.service = new Wt("", R(R({}, n), {
                            credentials: r.gateway.credentials,
                            amount: r.charge.amount,
                            currency: r.charge.currency,
                            gateway_mode: r.gateway.mode
                        }));
                        break;
                    case b.AFTERPAY:
                        this.service = new $t(t, R(R({}, n), {
                            id: r.charge.id,
                            gateway_mode: r.gateway.mode,
                            amount: r.charge.amount,
                            currency: r.charge.currency,
                            reference: r.charge.reference
                        }))
                }
            }
            return d(o, [{
                key: "load",
                value: function() {
                    try {
                        this.setupServiceCallbacks(), this.service.load(this.container)
                    } catch (e) {
                        throw this.eventEmitter.emit(an, null), e
                    }
                }
            }, {
                key: "update",
                value: function(e) {
                    this.service.update(e)
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.api.setEnv(e, t), this.service.setEnv(e)
                }
            }, {
                key: "close",
                value: function() {
                    "function" == typeof this.service.close && this.service.close()
                }
            }, {
                key: "on",
                value: function(e, t) {
                    var n = this;
                    return e === sn && (this.hasUpdateHandler = !0), "function" == typeof t ? this.eventEmitter.subscribe(e, t) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(e, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "onUnavailable",
                value: function(e) {
                    var t = this;
                    return "function" == typeof e ? this.eventEmitter.subscribe(an, e) : new Promise(function(e) {
                        return t.eventEmitter.subscribe(an, function() {
                            return e()
                        })
                    })
                }
            }, {
                key: "onUpdate",
                value: function(e) {
                    var n = this;
                    return this.hasUpdateHandler = !0, "function" == typeof e ? this.eventEmitter.subscribe(sn, e) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(sn, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "onPaymentSuccessful",
                value: function(e) {
                    var n = this;
                    return "function" == typeof e ? this.eventEmitter.subscribe(un, e) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(un, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "onPaymentInReview",
                value: function(e) {
                    var n = this;
                    return "function" == typeof e ? this.eventEmitter.subscribe(ln, e) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(ln, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "onPaymentError",
                value: function(e) {
                    var n = this;
                    return "function" == typeof e ? this.eventEmitter.subscribe(cn, e) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(cn, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "onAuthTokensChanged",
                value: function(e) {
                    var n = this;
                    return "function" == typeof e ? this.eventEmitter.subscribe(dn, e) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(dn, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "setupServiceCallbacks",
                value: function() {
                    this.setupUnavailableCallback(), this.setupUpdateCallback(), this.setupWalletCallback(), this.setupPaymentCallback(), this.setupPaymentSuccessCallback(), this.setupPaymentInReviewCallback(), this.setupPaymentErrorCallback(), this.setupAuthTokensChangedCallback()
                }
            }, {
                key: "setupUnavailableCallback",
                value: function() {
                    var t = this;
                    this.service.on(It.UNAVAILABLE, function(e) {
                        return t.eventEmitter.emit(an, {
                            event: an,
                            data: e
                        })
                    })
                }
            }, {
                key: "setupUpdateCallback",
                value: function() {
                    var t = this;
                    this.service.on(It.UPDATE, function(e) {
                        return t.hasUpdateHandler ? t.eventEmitter.emit(sn, {
                            event: sn,
                            data: e
                        }) : t.update({
                            success: !0
                        })
                    })
                }
            }, {
                key: "setupWalletCallback",
                value: function() {
                    var r = this;
                    this.service.on(It.CALLBACK, function(e) {
                        var t = e.data,
                            n = e.onSuccess,
                            i = e.onError;
                        r.api.charge().walletCallback(t).then(function(e) {
                            return n(e)
                        }, function(e) {
                            return i(e.message)
                        })
                    })
                }
            }, {
                key: "setupPaymentCallback",
                value: function() {
                    var r = this;
                    this.service.on(It.PAYMENT_METHOD_SELECTED, function(e) {
                        var n = e.data,
                            i = e.onSuccess,
                            t = e.onError;
                        r.api.charge().walletCapture(n).then(function(e) {
                            "function" == typeof i && i();
                            var t = "inreview" === e.status ? ln : un;
                            r.eventEmitter.emit(t, {
                                event: t,
                                data: R(R({}, e), n.customer && {
                                    payer_name: n.customer.payer_name,
                                    payer_email: n.customer.payer_email,
                                    payer_phone: n.customer.payer_phone
                                })
                            })
                        }, function(e) {
                            "function" == typeof t && t(e), r.eventEmitter.emit(cn, {
                                event: cn,
                                data: e
                            })
                        })
                    })
                }
            }, {
                key: "setupPaymentSuccessCallback",
                value: function() {
                    var t = this;
                    this.service.on(It.PAYMENT_SUCCESS, function(e) {
                        return t.eventEmitter.emit(un, {
                            event: un,
                            data: e
                        })
                    })
                }
            }, {
                key: "setupPaymentInReviewCallback",
                value: function() {
                    var t = this;
                    this.service.on(It.PAYMENT_IN_REVIEW, function(e) {
                        return t.eventEmitter.emit(ln, {
                            event: ln,
                            data: e
                        })
                    })
                }
            }, {
                key: "setupPaymentErrorCallback",
                value: function() {
                    var t = this;
                    this.service.on(It.PAYMENT_ERROR, function(e) {
                        return t.eventEmitter.emit(cn, {
                            event: cn,
                            data: e
                        })
                    })
                }
            }, {
                key: "setupAuthTokensChangedCallback",
                value: function() {
                    var t = this;
                    this.service.on(It.AUTH_TOKENS_CHANGED, function(e) {
                        return t.eventEmitter.emit(dn, {
                            event: dn,
                            data: e
                        })
                    })
                }
            }]), o
        }(),
        pn = function() {
            function n(e, t) {
                g(this, n), this.configs = [], this.configTokens = [], this.link = new ue("/payment-sources"), this.link.setParams(R({
                    query_token: t
                }, _.validateJWT(e) ? {
                    access_token: e
                } : {
                    public_key: e
                })), w.version && this.link.setParams({
                    sdk_version: w.version,
                    sdk_type: w.type
                })
            }
            return d(n, [{
                key: "setStyles",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setStyle(t, e[t])
                }
            }, {
                key: "setStyle",
                value: function(e, t) {
                    -1 !== ce.values(he).indexOf(e) ? this.link.setParams(k({}, e, t)) : console.warn("Widget::setStyle[s: unsupported style param ".concat(e))
                }
            }, {
                key: "setRefId",
                value: function(e) {
                    this.link.setParams({
                        ref_id: e
                    })
                }
            }, {
                key: "setLimit",
                value: function(e) {
                    this.link.setParams({
                        limit: e
                    })
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    for (var n in this.link.setEnv(e, t), this.configs) this.configs.hasOwnProperty(n) && this.configs[n].setEnv(e, t)
                }
            }, {
                key: "getEnv",
                value: function() {
                    this.link.getEnv()
                }
            }, {
                key: "getIFrameUrl",
                value: function() {
                    return this.link.getUrl()
                }
            }, {
                key: "filterByGatewayIds",
                value: function(e) {
                    this.link.setParams({
                        gateway_ids: e.join(",")
                    })
                }
            }, {
                key: "filterByTypes",
                value: function(e) {
                    var t, n = [],
                        i = function(e, t) {
                            var n = "undefined" != typeof Symbol && e[Symbol.iterator] || e["@@iterator"];
                            if (!n) {
                                if (Array.isArray(e) || (n = p(e)) || t && e && "number" == typeof e.length) {
                                    n && (e = n);
                                    var i = 0,
                                        r = function() {};
                                    return {
                                        s: r,
                                        n: function() {
                                            return i >= e.length ? {
                                                done: !0
                                            } : {
                                                done: !1,
                                                value: e[i++]
                                            }
                                        },
                                        e: function(e) {
                                            throw e
                                        },
                                        f: r
                                    }
                                }
                                throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")
                            }
                            var o, a = !0,
                                s = !1;
                            return {
                                s: function() {
                                    n = n.call(e)
                                },
                                n: function() {
                                    var e = n.next();
                                    return a = e.done, e
                                },
                                e: function(e) {
                                    s = !0, o = e
                                },
                                f: function() {
                                    try {
                                        a || null == n.return || n.return()
                                    } finally {
                                        if (s) throw o
                                    }
                                }
                            }
                        }(e);
                    try {
                        for (i.s(); !(t = i.n()).done;) {
                            var r = t.value;
                            e.hasOwnProperty(r) && (-1 === ce.values(le).indexOf(r) ? console.warn("PaymentSourceWidget::filterByTypes: unsupported type ".concat(r)) : n.push(r))
                        }
                    } catch (e) {
                        i.e(e)
                    } finally {
                        i.f()
                    }
                    this.link.setParams({
                        payment_source_types: n.join(",")
                    })
                }
            }, {
                key: "setLanguage",
                value: function(e) {
                    this.link.setParams({
                        language: e
                    })
                }
            }]), n
        }(),
        fn = function() {
            u(o, pn);
            var r = h(o);

            function o(e, t, n) {
                var i;
                return g(this, o), (i = r.call(this, t, n)).container = new Pe(e), i.iFrame = new xe(i.container), i.event = new Ie(window), i
            }
            return d(o, [{
                key: "load",
                value: function() {
                    this.iFrame.load(this.getIFrameUrl(), {
                        title: "Payment Sources"
                    })
                }
            }, {
                key: "on",
                value: function(e, t) {
                    this.event.on(e, this.link.getParams().widget_id, t)
                }
            }, {
                key: "hide",
                value: function(e) {
                    console.info("PayDock SDK"), this.iFrame.hide(e)
                }
            }, {
                key: "show",
                value: function() {
                    this.iFrame.show()
                }
            }, {
                key: "reload",
                value: function() {
                    this.iFrame.remove(), this.load()
                }
            }, {
                key: "onSelectInsert",
                value: function(t, n) {
                    this.on(Le.SELECT, function(e) {
                        Re.insertToInput(t, n, e)
                    })
                }
            }]), o
        }(),
        vn = {
            visibility: "hidden",
            border: "0",
            width: "0",
            height: "0"
        };
    (tn = en = en || {}).SUCCESS = "success", tn.ERROR = "error", tn.PENDING = "pending";
    var mn, yn, gn = "chargeAuthSuccess",
        kn = "chargeAuthReject",
        En = "chargeAuthDecoupled",
        _n = "chargeAuthChallenge",
        wn = "chargeAuthInfo",
        bn = "error",
        Cn = function() {
            function i(e, t, n) {
                g(this, i), this.container = e, this.api = t, this.eventEmitter = n, this.resultRead = !1, this.iFrameEvent = new Ie(window)
            }
            return d(i, [{
                key: "load",
                value: function(e, t) {
                    var n = e.initialization_url,
                        i = e.secondary_url,
                        r = e.charge_3ds_id;
                    try {
                        this.setupIFrameEvents(r), this.initializeIFrames(n, i, t)
                    } catch (e) {
                        this.eventEmitter.emit(bn, this.parseError(e, r))
                    }
                }
            }, {
                key: "initializeIFrames",
                value: function(e, t, n, i) {
                    var r = !(3 < arguments.length && void 0 !== i) || i,
                        o = this.container.getElement();
                    if (o) {
                        var a = document.createElement("div");
                        if (a.setAttribute("id", "paydock_authorization_iframe"), o.appendChild(a), this.browserAndChallengeContainer = new Pe("#paydock_authorization_iframe"), this.iFrameAuthorization = new xe(this.browserAndChallengeContainer), this.iFrameAuthorization.load(e, {
                                title: n
                            }), t) {
                            var s = document.createElement("div");
                            s.setAttribute("id", "paydock_secondary_iframe"), o.appendChild(s), this.monitoringContainer = new Pe("#paydock_secondary_iframe"), this.iFrameSecondaryUrl = new xe(this.monitoringContainer), this.iFrameSecondaryUrl.load(t, {
                                title: n
                            })
                        } else this.iFrameSecondaryUrl = void 0;
                        this.hideIframes(r)
                    }
                }
            }, {
                key: "hideIframes",
                value: function(e) {
                    var t, n = !(0 < arguments.length && void 0 !== e) || e;
                    for (var i in vn) vn.hasOwnProperty(i) && (n && this.iFrameAuthorization.setStyle(i, vn[i]), null !== (t = this.iFrameSecondaryUrl) && void 0 !== t && t.setStyle(i, vn[i]))
                }
            }, {
                key: "setupIFrameEvents",
                value: function(e) {
                    var t = this;
                    this.iFrameEvent.on(Le.CHARGE_AUTH, e, function(e) {
                        "MethodSkipped" === e.status || "MethodFinished" === e.status ? (e.info && t.eventEmitter.emit(wn, {
                            info: e.info
                        }), t.performAuthentication(e)) : "AuthTimedOut" !== e.status && "invalid_event" !== e.status || t.eventEmitter.emit(kn, t.parseHandleResponse({
                            status: e.status
                        }, e.charge_3ds_id))
                    }), this.iFrameEvent.on(Le.CHARGE_AUTH_SUCCESS, e, function(e) {
                        t.processResult(e.charge_3ds_id)
                    })
                }
            }, {
                key: "parseResultData",
                value: function(e, t) {
                    return {
                        status: e.status,
                        charge_3ds_id: t
                    }
                }
            }, {
                key: "parseHandleResponse",
                value: function(e, t) {
                    var n = e.status,
                        i = e.result;
                    return {
                        status: n,
                        charge_3ds_id: t,
                        result: {
                            description: null == i ? void 0 : i.description
                        }
                    }
                }
            }, {
                key: "parseError",
                value: function(e, t) {
                    return {
                        charge_3ds_id: t,
                        error: e
                    }
                }
            }, {
                key: "processResult",
                value: function(n) {
                    var i = this;
                    this.resultRead || (this.resultRead = !0, this.api.charge().standalone3dsHandle().then(function(e) {
                        var t;
                        i.iFrameAuthorization.remove(), null !== (t = i.iFrameSecondaryUrl) && void 0 !== t && t.remove(), e.status === en.SUCCESS ? i.eventEmitter.emit(gn, i.parseResultData(e, n)) : i.eventEmitter.emit(kn, i.parseResultData(e, n))
                    }, function(e) {
                        i.eventEmitter.emit(bn, i.parseError(e, n))
                    }))
                }
            }, {
                key: "externalAPI",
                value: function(e, t) {
                    var i = new XMLHttpRequest;
                    return i.open(e, t, !0), new Promise(function(t, n) {
                        i.onload = function() {
                            try {
                                var e = JSON.parse(i.responseText);
                                t(e)
                            } catch (e) {
                                n(e)
                            }
                        }, i.send()
                    })
                }
            }, {
                key: "doPolling",
                value: function(t, n) {
                    var i = this;
                    this.externalAPI("GET", t).then(function(e) {
                        if (e.event && "AuthResultNotReady" !== e.event) {
                            if ("AuthResultReady" !== e.event) throw new Error("Event not supported");
                            i.processResult(n)
                        } else setTimeout(function() {
                            i.doPolling(t, n)
                        }, 2e3)
                    }).catch(function(e) {
                        return i.eventEmitter.emit(bn, i.parseError(e, n))
                    })
                }
            }, {
                key: "performAuthentication",
                value: function(e) {
                    var t, i = this,
                        r = e.charge_3ds_id;
                    this.iFrameAuthorization.remove(), null !== (t = this.iFrameSecondaryUrl) && void 0 !== t && t.remove(), this.api.charge().standalone3dsProcess({
                        charge_3ds_id: r
                    }).then(function(e) {
                        var t, n;
                        if ("success" === e.status) i.eventEmitter.emit(gn, i.parseHandleResponse(e, r));
                        else {
                            if ("pending" !== e.status) return i.eventEmitter.emit(kn, i.parseHandleResponse(e, r));
                            null !== (t = null == e ? void 0 : e.result) && void 0 !== t && t.challenge ? (i.eventEmitter.emit(_n, i.parseHandleResponse(e, r)), i.initializeIFrames(e.result.challenge_url, void 0, "Authentication Challenge", !1), e.result.secondary_url && i.doPolling(e.result.secondary_url, r)) : null !== (n = null == e ? void 0 : e.result) && void 0 !== n && n.decoupled_challenge && (i.eventEmitter.emit(En, i.parseHandleResponse(e, r)), e.result.secondary_url && i.doPolling(e.result.secondary_url, r))
                        }
                    }, function(e) {
                        i.eventEmitter.emit(bn, i.parseError(e, r))
                    })
                }
            }]), i
        }(),
        Sn = "GPayments",
        Tn = function() {
            function n(e, t) {
                g(this, n), this.env = te, this.container = e, this.eventEmitter = t
            }
            return d(n, [{
                key: "load",
                value: function(e, t) {
                    var n = _.validateJWT(e);
                    if (!n) throw new Error("Invalid charge token");
                    var i = _.extractData(n.body),
                        r = new Qt(e, Ft.TOKEN);
                    switch (r.setEnv(this.env, this.alias), i.service_type) {
                        case Sn:
                            new Cn(this.container, r, this.eventEmitter).load(i, t.title)
                    }
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.env = e, this.alias = t
                }
            }]), n
        }();
    (yn = mn = mn || {}).HTML = "html", yn.URL = "url", yn.STANDALONE_3DS = "standalone_3ds";
    var On, An, Rn = function() {
            function n(e, t) {
                g(this, n), this.configs = [], this.link = new ue("/3ds/webhook"), this.token = n.extractToken(t), this.link.setParams({
                    ref_id: this.token.charge_3ds_id
                }), this.container = new Pe(e), this.iFrame = new xe(this.container), this.eventEmitter = new We, this.standalone3dsService = new Tn(this.container, this.eventEmitter), this.event = new Ie(window)
            }
            return d(n, [{
                key: "load",
                value: function() {
                    this.token.format === mn.HTML ? this.iFrame.loadFromHtml(this.token.content, {
                        title: "3d secure authentication"
                    }) : this.token.format === mn.URL ? this.iFrame.load(this.token.content, {
                        title: "3d secure authentication"
                    }) : this.token.format === mn.STANDALONE_3DS ? this.standalone3dsService.load(this.token.content, {
                        title: "3d secure authentication"
                    }) : console.error("Token contain unsupported payload")
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    for (var n in this.link.setEnv(e, t), this.standalone3dsService.setEnv(e, t), this.configs) this.configs.hasOwnProperty(n) && this.configs[n].setEnv(e, t)
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.link.getEnv()
                }
            }, {
                key: "on",
                value: function(e, t) {
                    var n = this;
                    return this.token.format === mn.STANDALONE_3DS ? "function" == typeof t ? this.eventEmitter.subscribe(e, t) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(e, function(e) {
                            return t(e)
                        })
                    }) : "function" == typeof t ? this.event.on(e, this.link.getParams().ref_id, t) : new Promise(function(t) {
                        return n.event.on(e, n.link.getParams().ref_id, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "hide",
                value: function(e) {
                    this.iFrame.hide(e)
                }
            }, {
                key: "show",
                value: function() {
                    this.iFrame.show()
                }
            }, {
                key: "reload",
                value: function() {
                    this.iFrame.remove(), this.load()
                }
            }], [{
                key: "extractToken",
                value: function(e) {
                    return JSON.parse(window.atob(e))
                }
            }]), n
        }(),
        Pn = "/v1/charges/3ds",
        xn = function() {
            function t(e) {
                g(this, t), this.api = e
            }
            return d(t, [{
                key: "preAuth",
                value: function(e, t) {
                    return "function" == typeof t ? this.api.getClient("POST", Pn).send(R(R({}, e), {
                        _3ds: R(R({}, e._3ds), {
                            browser_details: {
                                name: Je.getBrowserName(),
                                java_enabled: Je.isJavaEnabled().toString(),
                                language: Je.getLanguage(),
                                screen_height: Je.getScreenHeight().toString(),
                                screen_width: Je.getScreenWidth().toString(),
                                time_zone: Je.getTimezoneOffset().toString(),
                                color_depth: Je.getColorDepth().toString()
                            }
                        })
                    }), function(e) {
                        t(e)
                    }) : this.api.getClientPromise("POST", Pn).send(R(R({}, e), {
                        _3ds: R(R({}, e._3ds), {
                            browser_details: {
                                name: Je.getBrowserName(),
                                java_enabled: Je.isJavaEnabled().toString(),
                                language: Je.getLanguage(),
                                screen_height: Je.getScreenHeight().toString(),
                                screen_width: Je.getScreenWidth().toString(),
                                time_zone: Je.getTimezoneOffset().toString(),
                                color_depth: Je.getColorDepth().toString()
                            }
                        })
                    }))
                }
            }]), t
        }(),
        Ln = function() {
            u(i, Jt);
            var n = h(i);

            function i(e) {
                var t;
                return g(this, i), (t = n.call(this, e)).publicKey = t.auth, t
            }
            return d(i, [{
                key: "getBrowserDetails",
                value: function() {
                    return {
                        name: Je.getBrowserName(),
                        java_enabled: Je.isJavaEnabled().toString(),
                        language: Je.getLanguage(),
                        screen_height: Je.getScreenHeight().toString(),
                        screen_width: Je.getScreenWidth().toString(),
                        time_zone: Je.getTimezoneOffset().toString(),
                        color_depth: Je.getColorDepth().toString()
                    }
                }
            }, {
                key: "charge",
                value: function() {
                    return new xn(this)
                }
            }]), i
        }();
    (An = On = On || {}).AFTER_LOAD = "after_load", An.SYSTEM_ERROR = "system_error", An.CVV_SECURE_CODE_REQUESTED = "cvv_secure_code_requested", An.CARD_NUMBER_SECURE_CODE_REQUESTED = "card_number_secure_code_requested", An.ACCESS_FORBIDDEN = "access_forbidden", An.SESSION_EXPIRED = "session_expired", An.OPERATION_FORBIDDEN = "operation_forbidden";
    var In, Un, Dn, Nn, Mn = function() {
            u(t, Ie);
            var e = h(t);

            function t() {
                return g(this, t), e.apply(this, arguments)
            }
            return d(t, [{
                key: "on",
                value: function(e, t, n) {
                    for (var i in On) On.hasOwnProperty(i) && e === On[i] && this.listeners.push({
                        event: e,
                        listener: n,
                        widget_id: t
                    })
                }
            }]), t
        }(),
        Fn = function() {
            function n(e, t) {
                g(this, n), this.validationData = {}, this.configs = [], this.container = new Pe(e), this.iFrame = new xe(this.container), this.triggerElement = new De(this.iFrame), this.event = new Mn(window), this.vaultDisplayToken = t, this.link = new ue("/vault-display"), this.link.setParams({
                    vault_display_token: t
                })
            }
            return d(n, [{
                key: "setEnv",
                value: function(e, t) {
                    this.link.setEnv(e, t)
                }
            }, {
                key: "on",
                value: function(e, t) {
                    var n = this;
                    return "function" == typeof t ? this.event.on(e, this.link.getParams().widget_id, t) : new Promise(function(t) {
                        return n.event.on(e, n.link.getParams().widget_id, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "setStyles",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setStyle(t, e[t])
                }
            }, {
                key: "setStyle",
                value: function(e, t) {
                    -1 !== ce.values(he).indexOf(e) ? this.link.setParams(k({}, e, t)) : console.warn("Widget::setStyle[s: unsupported style param ".concat(e))
                }
            }, {
                key: "load",
                value: function() {
                    this.iFrame.load(this.link.getUrl(), {
                        title: "Vault Display"
                    })
                }
            }]), n
        }(),
        Hn = d(function e() {
            g(this, e)
        });
    Hn.buttonContainerStyles = "display: flex; flex-direction: column; justify-content: center; align-items: center;", Hn.buttonStyles = "color: #ffff; background-color: #ffbe24; border: none; width: 100%; min-height: 40px; font-size: 16px; font-weight: bold; line-height: 19px; letter-spacing: 0.7px; text-transform: uppercase; border-radius: 4px; margin-bottom: 15px; cursor: pointer;", Hn.footerContainerStyles = "display: flex; flex: 1; flex-wrap: wrap; justify-content: center;", Hn.footerTextStyles = "text-align: center; color: #666666; margin: 2px 0;", Hn.verticalLineStyle = "display: inline-block; padding: 0.5px; background-color: #E5E5E5; height: 15px;", Hn.clickToPayAllCardsStyle = "height: 17px; margin-left: 8px; vertical-align: middle; padding-top: 3px;", (Un = In = In || {}).CHECKOUT_BUTTON_LOADED = "checkoutButtonLoaded", Un.CHECKOUT_BUTTON_CLICKED = "checkoutButtonClicked", Un.IFRAME_LOADED = "iframeLoaded", Un.CHECKOUT_READY = "checkoutReady", Un.CHECKOUT_COMPLETED = "checkoutCompleted", Un.CHECKOUT_ERROR = "checkoutError", (Nn = Dn = Dn || {}).CRITICAL_ERROR = "CriticalError", Nn.USER_ERROR = "UserError", Nn.SUCCESS = "Success";
    var jn = {
            BUTTON_TEXT_COLOR: "button_text_color",
            PRIMARY_COLOR: "primary_color",
            FONT_FAMILY: "font_family",
            CARD_SCHEMES: "card_schemes"
        },
        Bn = "visa",
        zn = "mastercard",
        qn = "amex",
        Yn = "discover",
        Vn = "/images/visa-src/Chevron_Large_V.png",
        Wn = "/images/visa-src/vmad.svg",
        Kn = function(e, n) {
            return e.every(function(e, t) {
                return e === n[t]
            })
        },
        Gn = function() {
            function c(e, t, n, i, r, o, a, s, u) {
                g(this, c), this.meta = r, this.eventEmitter = o, this.autoResize = a, this.link = new ue("/secure-remote-commerce/visa"), this.link.setParams(R({
                    service_id: n,
                    public_key: i
                }, r && {
                    meta: JSON.stringify(r)
                })), w.version && this.link.setParams({
                    sdk_version: w.version,
                    sdk_type: w.type
                }), s && this.link.setEnv(s, u), this.iFrameContainer = new Pe(t), this.iFrame = new xe(this.iFrameContainer), this.buttonContainer = new Pe(e), this.iFrameEvent = new Ie(window), this.setupIFrameEvents()
            }
            return d(c, [{
                key: "setupIFrameEvents",
                value: function() {
                    var n = this,
                        e = this.link.getParams().widget_id;
                    this.iFrameEvent.on(In.CHECKOUT_READY, e, function(e) {
                        var t = e.data;
                        n.eventEmitter.emit(In.CHECKOUT_READY, t)
                    }), this.iFrameEvent.on(In.CHECKOUT_COMPLETED, e, function(e) {
                        var t = e.data;
                        n.eventEmitter.emit(In.CHECKOUT_COMPLETED, t)
                    }), this.iFrameEvent.on(In.CHECKOUT_ERROR, e, function(e) {
                        var t = e.data;
                        n.eventEmitter.emit(In.CHECKOUT_ERROR, t)
                    }), this.autoResize && this.useAutoResize(!0)
                }
            }, {
                key: "load",
                value: function() {
                    var e, t = this,
                        n = document.createElement("div");
                    n.setAttribute("style", Hn.buttonContainerStyles);
                    var i = document.createElement("button");
                    i.setAttribute("style", Hn.buttonStyles), this.meta.customizations.primary_color && (i.style.backgroundColor = this.meta.customizations.primary_color), this.meta.customizations.button_text_color && (i.style.color = this.meta.customizations.button_text_color), i.innerHTML = "Checkout";
                    var r = document.createElement("div");
                    r.setAttribute("style", Hn.footerContainerStyles), document.createElement("div").setAttribute("style", Hn.verticalLineStyle);
                    var o = document.createElement("p");
                    o.setAttribute("style", Hn.footerTextStyles), o.innerHTML = "WE ACCEPT";
                    var a = document.createElement("img");
                    a.setAttribute("style", Hn.clickToPayAllCardsStyle), a.src = this.link.getBaseUrl() + "".concat(function(e, t) {
                        var n = 1 < arguments.length && void 0 !== t && t;
                        if (!e || !Array.isArray(e)) return n ? "/images/visa-src/Chevron_Large_VMAD.png" : Wn;
                        var i = e.sort();
                        return Kn([qn, zn, Bn], i) ? n ? "/images/visa-src/Chevron_Large_VMA.png" : "/images/visa-src/logos/Networks_Large_VMA.png" : Kn([zn, Bn], i) ? n ? "/images/visa-src/Chevron_Large_VM.png" : "/images/visa-src/logos/Networks_Large_VM.png" : Kn([zn], i) ? n ? "/images/visa-src/Chevron_Large_M.png" : "/images/visa-src/logos/master-logo.png" : Kn([Yn], i) ? n ? "/images/visa-src/Chevron_Large_D.png" : "/images/visa-src/logos/Networks_Large_D.png" : Kn([Bn], i) ? n ? Vn : "/images/visa-src/logos/visa-logo.png" : n ? Vn : Wn
                    }(null === (e = this.meta.customizations) || void 0 === e ? void 0 : e.card_schemes, !0)), i.onclick = function() {
                        t.eventEmitter.emit(In.CHECKOUT_BUTTON_CLICKED, {}), t.iFrame.load(t.link.getUrl(), {
                            title: "Visa SRC checkout"
                        }), t.iFrame.getElement().onload = function() {
                            return t.eventEmitter.emit(In.IFRAME_LOADED, {})
                        }
                    }, n.appendChild(i), n.appendChild(r), r.appendChild(o), r.appendChild(a), this.buttonContainer.getElement().appendChild(n), this.eventEmitter.emit(In.CHECKOUT_BUTTON_LOADED, {})
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.link.getEnv()
                }
            }, {
                key: "hideButton",
                value: function() {
                    this.buttonContainer.getElement() && (this.buttonContainer.getElement().style.display = "none")
                }
            }, {
                key: "showButton",
                value: function() {
                    this.buttonContainer.getElement() && (this.buttonContainer.getElement().style.display = "block")
                }
            }, {
                key: "hideCheckout",
                value: function() {
                    this.iFrame && this.iFrame.hide()
                }
            }, {
                key: "showCheckout",
                value: function() {
                    this.iFrame && this.iFrame.show()
                }
            }, {
                key: "reload",
                value: function() {
                    this.iFrame.remove(), this.load()
                }
            }, {
                key: "useAutoResize",
                value: function(e) {
                    var n = this;
                    this.autoResize && !e || (this.autoResize = !0, this.iFrameEvent.on("resize", this.link.getParams().widget_id, function(e) {
                        var t = e.data;
                        n.iFrame.getElement() && (n.iFrame.getElement().scrolling = "no", t.height && n.iFrame.setStyle("height", t.height + "px"))
                    }))
                }
            }]), c
        }(),
        Jn = function() {
            function u(e, t, n, i, r, o, a, s) {
                g(this, u), this.meta = i, this.eventEmitter = r, this.autoResize = o, this.link = new ue("/secure-remote-commerce/mastercard"), this.link.setParams(R({
                    service_id: t,
                    public_key: n
                }, i && {
                    meta: JSON.stringify(i)
                })), w.version && this.link.setParams({
                    sdk_version: w.version,
                    sdk_type: w.type
                }), a && this.link.setEnv(a, s), this.iFrameContainer = new Pe(e), this.iFrame = new xe(this.iFrameContainer), this.iFrameEvent = new Ie(window), this.setupIFrameEvents()
            }
            return d(u, [{
                key: "setupIFrameEvents",
                value: function() {
                    var n = this,
                        e = this.link.getParams().widget_id;
                    e && (this.iFrameEvent.on(In.CHECKOUT_READY, e, function(e) {
                        var t = e.data;
                        n.eventEmitter.emit(In.CHECKOUT_READY, t)
                    }), this.iFrameEvent.on(In.CHECKOUT_COMPLETED, e, function(e) {
                        var t = e.data;
                        n.eventEmitter.emit(In.CHECKOUT_COMPLETED, t)
                    }), this.iFrameEvent.on(In.CHECKOUT_ERROR, e, function(e) {
                        var t = e.data;
                        n.eventEmitter.emit(In.CHECKOUT_ERROR, t)
                    }), this.autoResize && this.useAutoResize(!0))
                }
            }, {
                key: "load",
                value: function() {
                    var e = this;
                    this.iFrame.load(this.link.getUrl(), {
                        title: "Mastercard SRC checkout"
                    });
                    var t = this.iFrame.getElement();
                    t && (t.onload = function() {
                        return e.eventEmitter.emit(In.IFRAME_LOADED, {})
                    })
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.link.getEnv()
                }
            }, {
                key: "hideCheckout",
                value: function() {
                    this.iFrame && this.iFrame.hide()
                }
            }, {
                key: "showCheckout",
                value: function() {
                    this.iFrame && this.iFrame.show()
                }
            }, {
                key: "reload",
                value: function() {
                    this.iFrame.remove(), this.load()
                }
            }, {
                key: "useAutoResize",
                value: function(e) {
                    var o = this;
                    if (!this.autoResize || e) {
                        this.autoResize = !0;
                        var t = this.link.getParams();
                        null != t && t.widget_id && this.iFrameEvent.on("resize", t.widget_id, function(e) {
                            var t, n, i = e.data,
                                r = o.iFrame.getElement();
                            r && (r.scrolling = "no", null !== (t = null == i ? void 0 : i.data) && void 0 !== t && t.height && o.iFrame.setStyle("height", (null === (n = null == i ? void 0 : i.data) || void 0 === n ? void 0 : n.height) + "px"))
                        })
                    }
                }
            }]), u
        }(),
        Xn = function() {
            function o(e, t, n, i, r) {
                g(this, o), this.button_selector = e, this.iframe_selector = t, this.service_id = n, this.public_key_or_access_token = i, this.meta = r, this.autoResize = !1, this.style = {}, this.api = new Qt(i, Ft.PUBLIC_KEY), this.eventEmitter = new We
            }
            return d(o, [{
                key: "setStyles",
                value: function(e) {
                    for (var t in e) e.hasOwnProperty(t) && this.setStyle(t, e[t])
                }
            }, {
                key: "setStyle",
                value: function(e, t) {
                    -1 !== ce.values(jn).indexOf(e) ? this.style[e] = t : console.warn("Widget::setStyle[s: unsupported style param ".concat(e))
                }
            }, {
                key: "load",
                value: function() {
                    var n = this;
                    this.provider || this.api.service().getConfig(this.service_id).then(function(e) {
                        var t = e.type;
                        switch (n.meta.customizations = n.style, t) {
                            case Kt.VISA_SRC:
                                if (!n.button_selector) throw new Error("button_selector argument is required");
                                n.provider = new Gn(n.button_selector, n.iframe_selector, n.service_id, n.public_key_or_access_token, n.meta, n.eventEmitter, n.autoResize, n.env, n.alias);
                                break;
                            case Kt.MASTERCARD_SRC:
                                n.provider = new Jn(n.iframe_selector, n.service_id, n.public_key_or_access_token, n.meta, n.eventEmitter, n.autoResize, n.env, n.alias)
                        }
                        n.provider && n.provider.load()
                    })
                }
            }, {
                key: "setEnv",
                value: function(e, t) {
                    this.provider || (this.env = e, this.alias = t, this.api.setEnv(e, t))
                }
            }, {
                key: "getEnv",
                value: function() {
                    return this.provider ? this.provider.getEnv() : this.env
                }
            }, {
                key: "on",
                value: function(e, t) {
                    var n = this;
                    return "function" == typeof t ? this.eventEmitter.subscribe(e, t) : new Promise(function(t) {
                        return n.eventEmitter.subscribe(e, function(e) {
                            return t(e)
                        })
                    })
                }
            }, {
                key: "hideButton",
                value: function(e) {
                    this.provider && "function" == typeof this.provider.hideButton && this.provider.hideButton(e)
                }
            }, {
                key: "showButton",
                value: function() {
                    this.provider && "function" == typeof this.provider.showButton && this.provider.showButton()
                }
            }, {
                key: "hideCheckout",
                value: function(e) {
                    this.provider && "function" == typeof this.provider.hideCheckout && this.provider.hideCheckout(e)
                }
            }, {
                key: "showCheckout",
                value: function() {
                    this.provider && "function" == typeof this.provider.showCheckout && this.provider.showCheckout()
                }
            }, {
                key: "reload",
                value: function() {
                    this.provider && this.provider.reload()
                }
            }, {
                key: "useAutoResize",
                value: function() {
                    this.autoResize = !0, this.provider && "function" == typeof this.provider.useAutoResize && this.provider.useAutoResize()
                }
            }]), o
        }(),
        Zn = function() {
            u(a, Xn);
            var o = h(a);

            function a(e, t, n, i) {
                var r;
                return g(this, a), (r = o.call(this, void 0, e, t, n, i)).iframe_selector = e, r.service_id = t, r.public_key_or_access_token = n, r.meta = i, r
            }
            return d(a, [{
                key: "load",
                value: function() {
                    this.provider || (this.provider = new Jn(this.iframe_selector, this.service_id, this.public_key_or_access_token, this.meta, this.eventEmitter, this.autoResize, this.env, this.alias), this.provider.load())
                }
            }]), a
        }();
    e.AfterpayCheckoutButton = Ot, e.Api = Ln, e.CHECKOUT_BUTTON_EVENT = He, e.Canvas3ds = Rn, e.Configuration = be, e.ELEMENT = fe, e.EVENT = Le, e.ExternalCheckoutBuilder = Ye, e.ExternalCheckoutChecker = Ve, e.FORM_FIELD = de, e.HtmlMultiWidget = Me, e.HtmlPaymentSourceWidget = fn, e.HtmlWidget = Fe, e.MastercardSRCClickToPay = Zn, e.MultiWidget = Ae, e.PAYMENT_TYPE = _e, e.PURPOSE = we, e.PaymentSourceBuilder = bt, e.PaymentSourceWidget = pn, e.PaypalCheckoutButton = At, e.SRC = Xn, e.STYLABLE_ELEMENT = Ce, e.STYLABLE_ELEMENT_STATE = Se, e.STYLE = he, e.SUPPORTED_CARD_TYPES = ve, e.TEXT = pe, e.TRIGGER = Ue, e.TYPE = wt, e.VAULT_DISPLAY_STYLE = {
        BACKGROUND_COLOR: "background_color",
        TEXT_COLOR: "text_color",
        BORDER_COLOR: "border_color",
        BUTTON_COLOR: "button_color",
        FONT_SIZE: "font_size",
        FONT_FAMILY: "font_family"
    }, e.VaultDisplayWidget = Fn, e.WalletButtons = hn, e.ZipmoneyCheckoutButton = Tt, Object.defineProperty(e, "__esModule", {
        value: !0
    })
});
