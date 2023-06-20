#Analysis in QIIME2 
#random forest in QIIME2
qiime sample-classifier classify-samples \
--i-table moving-pictures-table.qza \
--m-metadata-file moving-pictures-sample-metadata.tsv \
--m-metadata-column body-site \
--p-optimize-feature-selection \
--p-parameter-tuning \
--p-estimator RandomForestClassifier \
--p-n-estimators 20 \
--p-random-state 123 \
--output-dir moving-pictures-classifier

qiime metadata tabulate \
--m-input-file moving-pictures-classifier/predictions.qza \
--o-visualization moving-pictures-classifier/predictions.qzv

qiime feature-table filter-features \
--i-table moving-pictures-table.qza \
--m-metadata-file moving-pictures-classifier/feature_importance.qza \
--o-filtered-table moving-pictures-classifier/important-feature-table.qza

qiime sample-classifier heatmap \
--i-table moving-pictures-table.qza \
--i-importance moving-pictures-classifier/feature_importance.qza \
--m-sample-metadata-file moving-pictures-sample-metadata.tsv \
--m-sample-metadata-column body-site \
--p-group-samples \
--p-feature-count 30 \
--o-filtered-table moving-pictures-classifier/important-feature-table-top-30.qza \
--o-heatmap moving-pictures-classifier/important-feature-heatmap.qzv

qiime sample-classifier predict-classification \
--i-table moving-pictures-table.qza \
--i-sample-estimator moving-pictures-classifier/sample_estimator.qza \
--o-predictions moving-pictures-classifier/new_predictions.qza \
--o-probabilities moving-pictures-classifier/new_probabilities.qza

qiime sample-classifier confusion-matrix \
--i-predictions moving-pictures-classifier/new_predictions.qza \
--i-probabilities moving-pictures-classifier/new_probabilities.qza \
--m-truth-file moving-pictures-sample-metadata.tsv \
--m-truth-column body-site \
--o-visualization moving-pictures-classifier/new_confusion_matrix.qzv

qiime sample-classifier regress-samples \
--i-table ecam-table.qza \
--m-metadata-file ecam-metadata.tsv \
--m-metadata-column month \
--p-estimator RandomForestRegressor \
--p-n-estimators 20 \
--p-random-state 123 \
--output-dir ecam-regressor
--o-visualization ecam-scatter.qzv


#ROC in QIIME2
qiime sample-classifier classify-samples \
--i-table moving-pictures-table.qza \
--m-metadata-file moving-pictures-sample-metadata.tsv \
--m-metadata-column body-site \
--p-optimize-feature-selection \
--p-parameter-tuning \
--p-estimator RandomForestClassifier \
--p-n-estimators 20 \
--p-random-state 123 \
--output-dir moving-pictures-classifier
