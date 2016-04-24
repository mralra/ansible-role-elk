import json


def kibana_dashboards(kibana_json):
    return [x for x in kibana_json if x['_type'] == 'dashboard']


def kibana_searches(kibana_json):
    return [x for x in kibana_json if x['_type'] == 'search']


def kibana_visualizations(kibana_json):
    return [x for x in kibana_json if x['_type'] == 'visualization']


class FilterModule(object):
    def filters(self):
        return {
            'kibana_dashboards': kibana_dashboards,
            'kibana_searches': kibana_searches,
            'kibana_visualizations': kibana_visualizations,
        }
