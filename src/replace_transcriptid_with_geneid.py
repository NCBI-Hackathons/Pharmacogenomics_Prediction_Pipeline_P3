from settings import  SettingsParser

conf = SettingsParser()
transcript_counts_file = conf.settings['data']['filtered']['exome_variants'][0]['file']
mapping_file = conf.settings['data']['raw']['ensg_to_enst'][0]['file']
transcript_to_gene = { line.strip().split()[1]:line.strip().split()[0] for line in open(mapping_file,'r').readlines()}

with open(transcript_counts_file,'r') as fh:
    # Get header, replace transcript id label with gene id
    header = fh.next()
    header = header.replace('transcript_id','GENE_ID')
    print header.strip()
    for row in fh:
        row=row.strip().split()
        gene_id = transcript_to_gene[row[0]]
        print "{}\t{}".format(gene_id, '\t'.join(row[1:]))
