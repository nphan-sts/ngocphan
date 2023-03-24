"""
Follow installation steps and intructions as mentioned on the SCHEMA_COMPARISON_README file
to run the script.
"""
from simple_salesforce import Salesforce, SFType
import pandas as pd
import json
from pathlib import Path
import duckdb
import time

s_object_metadata_errors = {}

def extract(config_file):
    """Read json file and return a dictionary"""
    with open(config_file) as f:
        salesforce_config = json.load(f)
    return salesforce_config


def set_connection(conf_conn):
    """Return Salesforce connection"""
    return Salesforce(**salesforce_config[conf_conn])


def fetch(sf:Salesforce, object_api_name):
    """Return object metadata using the sf connection and object name"""
    object_label = ""
    try:
        sf_object = SFType(object_api_name, sf.session_id, sf.sf_instance, sf.sf_version, sf.proxies)
        object_label = sf_object.describe()['label']
        fields = sf_object.describe()['fields']
    except Exception as e:
        s_object_metadata_errors[object_api_name] = e
        df = pd.DataFrame(columns=['object_label','label','api_name','type','object_api_name'])
        return df
    field_labels = [field['label'] for field in fields]
    field_names = [field['name'] for field in fields]
    field_types = [field['type'] for field in fields]
    df = pd.DataFrame({'object_label':object_label,'label': field_labels,'api_name': field_names, 'type': field_types})
    df["object_api_name"] = object_api_name
    return df


def compare():
    """Compare source metadata and target metadata and return the difference"""
    schema_comparison_query = """
    select
        src.object_label as Src_Object_Label, 
        src.object_api_name as Src_Object_APIName,
        src.label as Src_Field_Label, 
        src.api_name as Src_Field_APIName,
        src.type as Src_Field_Type,
        tgt.object_label as Tgt_Object_Label,
        tgt.object_api_name as Tgt_Object_APIName,
        tgt.label as Tgt_Field_Label, 
        tgt.api_name as Tgt_Field_APIName,
        tgt.type as Tgt_Field_Type,
        case 
        when src.object_api_name is not null and tgt.object_api_name is not null
        then 'Y'
        else 'N' end as Field_Type_Mismatch
    from source_df src
    full outer join target_df tgt 
    on (src.object_api_name = tgt.object_api_name
        and src.api_name = tgt.api_name)
    where coalesce(src.type,'null') != coalesce(tgt.type,'null')
    """
    return duckdb.query(schema_comparison_query).to_df()

if __name__ == "__main__":
    tm = time.strftime('%d %b %Y %H:%M:%S')
    config_file=input('Enter the full path of the config file: ')
    print('{}: Configuration file location: {}'.format(tm, config_file))
    source=input('Enter 1st Salesforce instance name to compare. Eg. [qa,stage]: ')
    print('{}: Source salesforce instance: {}'.format(tm, source))
    target=input('Enter 2nd Salesforce instance name to compare. Eg. [qa,stage]: ')
    print('{}: Target salesforce instance: {}'.format(tm, target))
    print('{}: Extracting configurations from {}'.format(tm, config_file))
    salesforce_config = extract(config_file)
    print('{}: Configurations extracted from file!'.format(tm))
    source_conn = set_connection(source)
    print('{}: {} instance connection setup!'.format(tm, source))
    target_conn = set_connection(target)
    print('{}: {} instance connection setup!'.format(tm, target))
    s_objects = salesforce_config["SObjects"]
    print('{}: Objects to compare fetched from config file!'.format(tm))
    print('{}: Fetching data for {} instance......'.format(tm, source))
    source_df = pd.concat([fetch(source_conn, s_object) for s_object in s_objects])
    print('{}: Data fetch complete for {} instance!'.format(tm, source))
    print('{}: Fetching data for {} instance......'.format(tm, target))
    target_df = pd.concat([fetch(target_conn, s_object) for s_object in s_objects])
    print('{}: Data fetch complete for {} instance!'.format(tm, target))
    print('{}: Comparing {} and {} instances......'.format(tm, source, target))
    comparison_df = compare()
    print('{}: Comparison complete!!'.format(tm))
    comparison_output = "schema_difference.csv"
    print('{}: Output file name: {}'.format(tm, comparison_output))
    print('{}: Outful file is being generated.....'.format(tm))
    comparison_df.to_csv(comparison_output,index=False)
    print('{}: Output file {} generated with comparison data!'.format(tm, comparison_output))
    print(s_object_metadata_errors.keys())