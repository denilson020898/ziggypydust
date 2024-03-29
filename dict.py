from zigffi import _lib

partner_dict = {
    'CJT-1585': {
        'display_name': 'CJT-1585',
        'partner_id': 71934,
        'partner_user_id': None,
        'schedule_cost': 'monthly'
    },
    'CON10850': {
        'display_name': 'CON10850',
        'partner_id': 71948,
        'partner_user_id': None,
        'schedule_cost': 'monthly'
    },
}
print(_lib.variadic("Son", partner_dict, '😊😊'))
print(_lib.variadic("Son", partner_dict, 'AA'))
