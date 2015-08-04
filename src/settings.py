import os
import yaml

class SettingsParser(object):
    SETTINGS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'settings.yaml')

    def __init__(self):
        with open(self.SETTINGS_FILE) as fh:
            self.data = yaml.load(fh)

j = SettingsParser()
print j.SETTINGS_FILE
print j.data['data']['raw']

