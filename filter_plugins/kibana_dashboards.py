import json


def kibana_dashboards(kibana_json):
    return [x for x in kibana_json if x['_type'] == 'dashboard']


def kibana_visualizations(kibana_json):
    return [x for x in kibana_json if x['_type'] == 'visualization']


def kibana_searches(kibana_json):
    return [x for x in kibana_json if x['_type'] == 'search']
