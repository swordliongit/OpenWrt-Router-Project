odoo.define("modem.ModemWarning", function (require) {
    const FormRenderer = require("web.FormRenderer");
    const { Component } = owl;
    const { ComponentWrapper } = require("web.OwlCompatibility");
    const { useState } = owl;

    class ModemWarning extends Component {
        modem = useState({});
        constructor(self, modem) {
            super();
            this.modem = modem;
        }
    //
    };
    /**
    * Register properties to our widget.
    */
    Object.assign(ModemWarning, {
        template: "Warning"
    });
    /**
    * Override the form renderer so that we can mount the component on render
    * to any div with the class o_partner_order_summary.
    */
    FormRenderer.include({
        async _renderView() {
            await this._super(...arguments);
            for(const element of this.el.querySelectorAll(".o_partner_order_summary")) {
                this._rpc({
                model: "modem.profile",
                method: "read",
                args: [[]]
            }).then(data => {
                (new ComponentWrapper(
                    this,
                    ModemWarning,
                    useState(data[0])
                )).mount(element);
                });
            }
        }
    });
});