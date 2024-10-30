# -*- coding: utf-8 -*-
from odoo import models, fields, api


class ModemWizardSite(models.TransientModel):
    _name = "modem.wizard.site"
    _description = "Modem Wizard Site"

    site = fields.Many2one("modem.profile.site", string="Site")

    # @api.model
    # def fields_view_get(self, view_id=None, view_type="form", toolbar=False, submenu=False):
    #     res = super(ModemWizardSite, self).fields_view_get(
    #         view_id=view_id, view_type=view_type, toolbar=toolbar, submenu=submenu
    #     )
    #     active_ids = self.env.context.get("active_ids", [])
    #     modems = self.env["modem.profile"].browse(active_ids)
    #     for modem in modems:
    #         modem.lock_modem()
    #     return res

    # def reject_modem_site_information(self):
    #     active_ids = self.env.context.get("active_ids", [])
    #     modems = self.env["modem.profile"].browse(active_ids)
    #     for modem in modems:
    #         modem.unlock_modem()
    #     return {"type": "ir.actions.act_window_close"}

    # wizard's save button
    def update_modem_site_information(self):
        # find active modems
        active_ids = self.env.context.get("active_ids", [])
        modems = self.env["modem.profile"].browse(active_ids)

        # ip_digits = ""
        # # if the user didn't provide any ip, we will skip ip generation
        # if self.ip != False:
        #     ip_digits = self.ip.split('.')

        # ip_lastdigit_shifter = 0
        for modem in modems:
            # generate ips
            # if self.ip != False:
            if self.site.id != False:
                site = self.env["modem.profile.site"].sudo().search([("id", "=", self.site.id)], limit=1)
                modem.write(
                    {
                        "site": site.id,
                        "channel": site.channel,
                        "enable_wireless": site.enable_wireless,
                        "ssid1": site.ssid1,
                        "ssid2": site.ssid2,
                        "ssid3": site.ssid3,
                        "enable_ssid1": site.enable_ssid1,
                        "enable_ssid2": site.enable_ssid2,
                        "enable_ssid3": site.enable_ssid3,
                        "passwd_1": site.passwd_1,
                        "passwd_2": site.passwd_2,
                        "passwd_3": site.passwd_3,
                        "vlanId": site.vlanId,
                    }
                )
            modem.check_context()
        # close the wizard
        return {"type": "ir.actions.act_window_close"}
