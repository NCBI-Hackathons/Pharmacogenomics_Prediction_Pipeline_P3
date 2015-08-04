import os
import json

class SettingsParser(object):
    SETTINGS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'settings.json')

    def __init__(self):
        with open(self.SETTINGS_FILE) as fh:
            self.data = json.load(fh)

j = SettingsParser()
print j.SETTINGS_FILE
print j.data

