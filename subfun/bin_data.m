function to_plot = bin_data(to_plot, nb_bins, opt)

tmp = zeros(size(to_plot,1),nb_bins);

t_start = 1;
t_end = opt.bin_size;

for iBin = 1:nb_bins
    tmp(:,iBin) = sum(to_plot(:,t_start:t_end), 2);
    t_start = t_start + opt.bin_size;
    t_end = t_end + opt.bin_size;
end

to_plot = tmp;

end