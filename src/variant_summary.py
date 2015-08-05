import os
import glob
import pprint

from settings import SettingsParser
from reader import ExomeVariantReader

conf = SettingsParser()
exome_annotation_files = conf.settings['data']['raw']['exome_vcfs']['path']

files = glob.glob(os.path.join(exome_annotation_files, "*.txt"))

class Counts():

    def __init__(self):
        self._data = {}
        self._features = []
        self._cell_lines = []

    @property
    def data(self):
        return self._data

    def insert(self,feature_id, cell_line):
        self._features.append(feature_id)
        self._cell_lines.append(cell_line)

        if  feature_id in self._data:
            if cell_line in self._data[feature_id]:
                self._data[feature_id][cell_line] += 1
            else:
                self._data[feature_id][cell_line] = 1
        else:
            self._data[feature_id]={}
            self._data[feature_id][cell_line] = 1
    
    @property
    def features(self):
        return set(self._features)

    @property
    def cell_lines(self):
        return set(self._cell_lines)

    def write_data_to_file(self, feature_name=None, filename=None):
        fh = open(filename,'w')
        header = [feature_name]
        header = header + list(self.cell_lines)
        fh.write("\t".join(header)+"\n")
        for feature in self.features:
            counts=[]
            for cell in self.cell_lines:
                if  cell in self.data[feature]:
                    counts.append(self.data[feature][cell])
                else:
                    counts.append(0)
            counts_as_str = [str(i) for i in counts]
            fh.write("{}\t{}\n".format(feature,'\t'.join(counts_as_str)))
        fh.close()


def extract_cell_line_name(filename):
    s= os.path.basename(filename).split('_')
    return "{}_{}".format(s[0],s[1])

effect_counter = Counts()
impact_counter = Counts()
for annofile in files:
    # extract cell line name
    cell_line =  extract_cell_line_name(annofile)
    filehandle = ExomeVariantReader(annofile)
    rows = filehandle.get_dictreader()
    for r in rows:
        effect_counter.insert(r['EFF[*].EFFECT'],cell_line)
        impact_counter.insert(r['EFF[*].IMPACT'],cell_line)
effect_counter.write_data_to_file(feature_name='SNP_EFFECT',
                                  filename='/data/datasets/filtered/exome_variants/snp_effect_per_cell_line.txt')
impact_counter.write_data_to_file(feature_name='SNP_IMPACT', 
                                  filename='/data/datasets/filtered/exome_variants/snp_impact_per_cell_line.txt')

