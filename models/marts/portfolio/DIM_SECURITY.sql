{{ self_completing_dimension(
    dim_rel = ref('REF_SECURITY_INFO_ABC_BANK'),
    dim_key_column = 'SECURITY_CODE',
    dim_default_key_value = '-1',
    rel_column_to_exclude = ['SECURITY_HKEY','SECURITY_HDIFF'],
    fact_defs = [{'model':target.database ~ '.' ~ target.schema ~ '_REFINED.REF_POSITION_ABC_BANK', 'key':'SECURITY_CODE'}]
) }}