import os
import csv


class Reader(object):
    """
    This is an abstract class and not to be used as is.
    """
    HEADER=[]
    INPUT_DELIMITER='\t'
    OUTPUT_DELIMITER='\t'
    
    def __init__(self):
        self._filename=None
        self._filehandle=None

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

    def is_valid_fieldname(self, feild):
        if feild in self.HEADER:
            return True
        return False

    def get_dictreader(self):
        rows =  csv.DictReader(self.filehandle,
                              delimiter=self.INPUT_DELIMITER,
                              fieldnames=self.HEADER)
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


COLUMNS = ['GENE_ID','ALMC1_DJ','ALMC2_DJ','AMO1_DSMZ','ANBL6_DJ2','ARD_JJKsccE7','ARP1_JJKsccF8','CAG_JJKsccG6','COLO677_DSMZ','Delta47_JCRB','DP6_DJ','EJM_DSMZ','FLAM76_JCRB','FR4_PLB','H1112_PLB','INA6_PLB','JIM1_ECACC','JIM3_ECACC','JJN3_DSMZ','JK6L_PLB','JMW1_PLB','Karpas25_ECACC','Karpas417_ECACC','Karpas620_DSMZ','Karpas929_ECACC','KAS61_DJ','KHM11_PLB','KHM1B_JCRB','KMM1_JCRB','KMS11_JCRBadh','KMS11_JCRBsus','KMS11_JPN','KMS12BM_JCRB','KMS12PE_JCRB','KMS18_PLB','KMS20_JCRB','KMS21BM_JCRB','KMS26_JCRB','KMS27_JCRB','KMS28BM_JCRB','KMS28PE_JCRB','KMS34_JCRB','KP6_DJ','L363_DSMZ','LP1_DSMZ','MM1R_ATCC','MM1S_ATCC','MMM1_PLB','MOLP2_DSMZ','MOLP8_DSMZ','NCIH929_DSMZ','OCIMY1_PLB','OCIMY5_PLB','OCIMY7_PLB','OH2_PLB','OPM1_PLB','OPM2_DSMZ','PCM6_Riken','PE1_PLB','PE2_PLB','RPMI8226_ATCC','SKMM1_PLB','SKMM2_DSMZ','U266_ATCC','UTMC2_PLB','VP6_DJ','XG1_PLB','XG2_PLB','XG6_PLB','XG7_PLB']
FILENAME='/home/ubuntu/usevani/HMCL_ensembl74_Counts.txt'

r = Reader()
r.HEADER = COLUMNS
r.filename=FILENAME
r.extract_to_file(fieldnames=['GENE_ID','SKMM2_DSMZ'],output_file='delme')
