# -*- coding: utf-8 -*-
{
    "name": "Master Modem",
    "summary": """
        Short (1 phrase/line) summary of the module's purpose, used as
        subtitle on modules listing or apps.openerp.com""",
    "description": """
        Long description of module's purpose
    """,
    "author": "SWORDLION",
    "website": "http://www.yourcompany.com",
    # Categories can be used to filter modules in modules listing
    # Check https://github.com/odoo/odoo/blob/15.0/odoo/addons/base/data/ir_module_category_data.xml
    # for the full list
    "category": "Uncategorized",
    "version": "0.1",
    # any module necessary for this one to work correctly
    "depends": ["base"],
    # always loaded
    "data": [
        "security/ir.model.access.csv",
        "wizard/modem_wizard_specific.xml",
        "wizard/modem_wizard.xml",
        "wizard/modem_wizard_site.xml",
        "views/modem_view.xml",
        # "data/ir_cron_data.xml",
        "data/server_actions.xml",
        # "data/modem_profile_site_default.xml"
        # "views/templates.xml",
    ],
    # only loaded in demonstration mode
    "demo": [
        "demo/demo.xml",
    ],
    'assets': {
        'web.assets_backend': [
            "modem/static/src/js/load_js_function.js",
            "modem/static/src/css/main.css",
            "modem/static/src/js/ModemWarning.js",
        ],
        'web.assets_qweb': [
            'modem/static/src/xml/Warning.xml',
        ],
    }
    # "post_init_hook": "_start_custom_cron",
}
