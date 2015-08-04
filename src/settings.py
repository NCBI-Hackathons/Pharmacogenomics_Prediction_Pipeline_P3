import os
import yaml

class SettingsParser(object):
    SETTINGS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'settings.yaml')

    def __init__(self):
        self._settings=None
    
    @property
    def settings(self):
        if self._settings is None:
            with open(self.SETTINGS_FILE) as fh:
                self._settings = yaml.load(fh)
                return self._settings
        else:
            return self._settings
# Usage
#j = SettingsParser()
#print j.SETTINGS_FILE
#print j.settings['data']['raw']

