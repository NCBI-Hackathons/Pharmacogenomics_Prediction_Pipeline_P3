#
# Pharmacogenomics Prediction Pipeline - Drug Sensitivity Visualization
#
# https://github.com/DCGenomics/Pharmacogenomics_Prediction_Pipeline_P3
#
library(shiny)
library(MASS)
library(ggplot2)
library(matrixStats)

options(stringsAsFactors=FALSE)
options(shiny.trace=TRUE)

# Filepaths
base_dir            = "/data/datasets/filtered/"
rnaseq_input        = file.path(base_dir, "rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv")
exome_input         = file.path(base_dir, "exome_variants/genes_per_cell_line.txt")
drug_response_input = file.path(base_dir, "drug_response/iLAC50_filtered.csv")

gene_expr = read.csv(rnaseq_input, row.names=1)
gene_snps = read.delim(exome_input, row.names=1)
drug_data = read.csv(drug_response_input, row.names=1)

# Drop cell lines without drug data
gene_expr = gene_expr[,colnames(gene_expr) %in% colnames(drug_data)]
gene_snps = gene_snps[,colnames(gene_snps) %in% colnames(drug_data)]

# Cell line names
cell_lines = colnames(drug_data)

# Testing -- for now, only show options for 1000 most variable genes
variances = rowVars(as.matrix(gene_expr))
var_cutoff = as.numeric(quantile(variances, 0.99))
gene_choices = rownames(gene_expr)[variances > var_cutoff]

drug_choices = rownames(drug_data)[1:10]

#
# Server
#
server = function(input, output, session) {
    output$gene_expr = renderPlot({
        df = data.frame(
            cell_line=cell_lines,
            gene=as.numeric(gene_expr[rownames(gene_expr)  == input$gene,]),
            agent=as.numeric(drug_data[rownames(drug_data) == input$drug,]),
            exome=as.numeric(gene_snps[rownames(gene_snps) == input$gene,])
        )
        #df = df[complete.cases(df),]
        plt = ggplot(df, aes(gene, agent))
    
        # color by exome data if present
        if (all(is.na(df$exome))) {
            plt = plt + geom_point()
        } else {
            plt = plt + geom_point(aes(colour=factor(exome)))
        }

        plt + geom_smooth(method=input$smooth_method) +
            xlab(sprintf("Log2-CPM Expression (%s)", input$gene)) +
            ylab(sprintf("Log-AC50 (%s)", input$drug)) +
            ggtitle("Log AC50 vs. Expression")
    })
}

#
# UI
#
ui = fluidPage(
  # Application title
  titlePanel("Pharmacogenomics Prediction Pipeline - Drug Sensitivity Visualization"),

  sidebarLayout(
    sidebarPanel(
      selectInput("drug", "Drug:", choices=drug_choices),
      selectInput("gene", "Gene:", choices=gene_choices),
      selectInput("smooth_method", "Smooth method:", 
                  choices=c('lm', 'rlm', 'loess')),
      width=2
    ),
    mainPanel(plotOutput("gene_expr", height=640))
  )
)

# Launch app
shinyApp(ui=ui, server=server)

