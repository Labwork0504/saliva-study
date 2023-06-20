#Lefse in Python
lefse-format_input.py data.txt lefse.in -c 1 -u 2 -o -1
run_lefse.py lefse.in lefse_results.txt -y 1
lefse-plot_features.py --width 15 --format png --dpi 300 lefse.in lefse_results.txt lefse_diff_taxa/
  plot_res.py lefse_results.txt lefse_effect_size_rank.pdf --format pdf
plot_cladogram.py lefse_results.txt lefse_cladogram.pdf  --format pdf --labeled_start_lev 1

