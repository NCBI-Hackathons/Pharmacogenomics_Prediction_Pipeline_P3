import os
import csv


class Reader(object):
    """
    This is an abstract class and not to be used as is.
    Expects the text files start with a header
    """
    INPUT_DELIMITER='\t'
    OUTPUT_DELIMITER='\t'
    
    def __init__(self):
        self._filename=None
        self._filehandle=None
        self._header=None

    @property
    def filename(self):
        return self._filename

    @filename.setter
    def filename(self, path):
        if not os.path.exists(path): 
            raise IOError("{} does not exists.".format(path))
        self._filename=path

    @property
    def filehandle(self):
        if self._filehandle is not None: return self._filehandle

        if self._filename is None:
            raise RuntimeWarning("Input file not provided.")
        
        else:
            self._filehandle = open(self._filename)
            return self._filehandle
    
    @property
    def header(self):
        if self._header is None:
            self._header = self.filehandle.next().strip().split(self.INPUT_DELIMITER)
        return self._header

    def is_valid_fieldname(self, feild):
        if feild in self.header:
            return True
        return False

    def get_dictreader(self):
        rows =  csv.DictReader(self.filehandle,
                              delimiter=self.INPUT_DELIMITER,
                              fieldnames=self.header)
        return rows

    def extract_data(self, fieldnames):
        rows = self.get_dictreader()
        # There has to be a better way to do this,
        # but i can't think of one right now.
        for row in rows:
            out=[]
            for f in fieldnames:
                out.append(row[f])
            yield out 

    def extract_to_file(self, fieldnames, output_file):
        with open(output_file,'w') as fh:
            rows = self.extract_data(fieldnames)
            for r in rows:
                fh.write("{}\n".format(self.OUTPUT_DELIMITER.join(r)))

    def extract_to_stdout(self, fieldnames):
        rows = self.extract_data(fieldnames)
        for r in rows:
            print("{}".format(self.OUTPUT_DELIMITER.join(r)))


class RnaSeqExpressionReader(Reader):
    INPUT_DELIMITER=','

class EnsemblToGOMappings(Reader):
    INPUT_DELIMITER='\t'

FILENAME='/data/datasets/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv'
r = RnaSeqExpressionReader()
r.filename=FILENAME
print r.header
r.extract_to_stdout(fieldnames=['GENE_ID','SKMM2_DSMZ'])
