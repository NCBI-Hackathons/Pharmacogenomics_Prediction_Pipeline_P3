# runClassifier.R
# Paul Aiyetan, MD
# August 03, 2015

runClassifier <- 
  function(obsMatrix, # explanatory variables (matrix)
           respVector, # response variable (vector)
           logTransform = TRUE,
           crossCompare = TRUE,
           cutOffs  # vector of cut-off points to classify response variable as responded (+1) or non-response(0) 
           ){ 
       responseBinList <- list()
       responseBinList <- lapply(cutOffs, function(x,y=responseVector){
                                  binResponseVector <- unlist(lapply(y, function(z){
                                      if(z < x){
                                        return(1) # response 
                                      }else{
                                        return(0) # non response 
                                      } 
                                   }))
                                }
       names(responseBinList) <- as.character(cutOffs)
       par(mfrow(length(responseBinList),3))
       png( 
       for(i in 1:length(responseBinList)){
           # for each of the response binary derived from the varying cutOffs
           
           combinedMatrix <- cbind(obsMatrix, responseBinList[[i]])
           colnames( combinedMatrix ) <- c(colnames(obsMatrix),"PharmacologicResponse")
           # devide data into training and validation sets
           #tSize = length(integer(nrow(combinedMatrix)/2))
           #trainingSetRows <- 
           #     sample(x=nrow(combinedMatrix), 
           #         size = tSize, replace = FALSE, prob = NULL) 
           #trainingSet <-  combinedMatrix[trainingSetRows,]   
           
           predictions <- c()
           labels <- c()
           # leave-one-out-validation
           for(i in 1:nrow(combinedMatrix)){
              labels <- c(labels, as.numeric(combinedMatrix[ i,"PharmacologicResponse"]))
              trainingSet <-  combinedMatrix[-c(i), ]
              model <- glm(PharmacologicResponse ~ , data = trainingSet,   family = "binary"  ) # model-training 
              prediction <- predict(model, combinedMatrix[i, ], type="response") # model-validation
                ## recompute logistic regression and perform prediction...
              predictions <- c(predictions, prediction)
           }
           require(ROCR)           
           roc <- list(predictions = predictions, 
                          labels = labels)             
           ## computing a simple ROC curve (x-axis: fpr, y-axis: tpr)
            # str(roc)
            # List of 2
            #  $ predictions: num ... (numeric vector of probabilities...)
            #  $ labels     : num ... (numeric vector of labels 1s and/or 0s)         
      
           pred <- prediction( roc$predictions, ROCR.simple$labels)
           perf <- performance(pred,"tpr","fpr")
           plot(perf, las=2, col = "red")
    
           ## precision/recall curve (x-axis: recall, y-axis: precision)
           perf1 <- performance(pred, "prec", "rec")
           plot(perf1, las=2, col = "red")
    
           ## sensitivity/specificity curve (x-axis: specificity,
           ## y-axis: sensitivity)
           perf2 <- performance(pred, "sens", "spec")
           plot(perf2, las=2, col = "red")                           
       }                              
  }