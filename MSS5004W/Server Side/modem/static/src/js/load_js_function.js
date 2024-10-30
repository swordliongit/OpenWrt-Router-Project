odoo.define('modem.load_js_function', function (require) {
    "Use strict";

    var core = require('web.core');
    var AbstractAction = require('web.AbstractAction');

    var LoadJSFunction = AbstractAction.extend({
        start: function () {
            console.log("TEST TEST TEST")

            return this._super.apply(this, arguments);
        },
    });

    core.action_registry.add('js_function', LoadJSFunction);

    return LoadJSFunction;
});
