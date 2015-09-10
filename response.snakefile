samples = []
for line in open('celllines.txt'):
    if line.startswith("#"):
        continue
    samples.append(line.strip())

targets = expand('example_data/processed/response/drc/{sample}_drc.tab', sample=samples)
targets += expand('example_data/processed/response/response/{sample}_response.tab', sample=samples)

rule target:
    input: targets

rule process_response:
    input: 'example_data/raw/drug_response/s-tum-{sample}-x1-1.csv'
    output:
        response_file='example_data/processed/response/response/{sample}_response.tab',
        drc_file='example_data/processed/response/drc/{sample}_drc.tab'
    shell:
        """
        Rscript tools/drug_response_filter_by_cclass2.R 
        """

# vim: ft=python
