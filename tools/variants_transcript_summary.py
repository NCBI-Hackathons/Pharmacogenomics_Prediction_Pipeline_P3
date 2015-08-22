import os
import glob
import pprint

from settings import SettingsParser
from reader import ExomeVariantReader

conf = SettingsParser()
exome_annotation_files = conf.settings['data']['raw']['exome_vcfs']['path']

files = glob.glob(os.path.join(exome_annotation_files, "*.txt"))

class TranscriptCountsbySample():

    def __init__(self):
        self._data = {}
        self._transcripts = []
        self._cell_lines = []

    @property
    def data(self):
        return self._data

    def insert(self,transcript_id, cell_line):
        self._transcripts.append(transcript_id)
        self._cell_lines.append(cell_line)

        if  transcript_id in self._data:
            if cell_line in self._data[transcript_id]:
                self._data[transcript_id][cell_line] += 1
            else:
                self._data[transcript_id][cell_line] = 1
        else:
            self._data[transcript_id]={}
            self._data[transcript_id][cell_line] = 1
    
    @property
    def transcripts(self):
        return set(self._transcripts)

    @property
    def cell_lines(self):
        return set(self._cell_lines)

    def print_as_matrix(self):
        header = ['transcript_id']
        header = header + list(self.cell_lines)
        print "\t".join(header)
        for transcript in self.transcripts:
            counts=[]
            for cell in self.cell_lines:
                if  cell in self.data[transcript]:
                    counts.append(self.data[transcript][cell])
                else:
                    counts.append(0)
            counts_as_str = [str(i) for i in counts]
            print "{}\t{}".format(transcript,'\t'.join(counts_as_str))



def extract_cell_line_name(filename):
    s= os.path.basename(filename).split('_')
    return "{}_{}".format(s[0],s[1])

counter = TranscriptCountsbySample()
for annofile in files:
    # extract cell line name
    cell_line =  extract_cell_line_name(annofile)
    filehandle = ExomeVariantReader(annofile)
    rows = filehandle.get_dictreader()
    for r in rows:
        counter.insert(r['EFF[*].TRID'],cell_line)
counter.print_as_matrix()

# Debug statements
#pprint.pprint(counter.data)
#pprint.pprint(len(counter.transcripts))
#pprint.pprint(len(counter.cell_lines))
