low_pass_decomp = [-0.12940952255092145, 0.22414386804185735, 0.836516303737469, 0.48296291314469025];
high_pass_decomp = [-0.48296291314469025, 0.836516303737469, -0.22414386804185735, -0.12940952255092145];

low_pass_recomp = [0.48296291314469025, 0.836516303737469, 0.22414386804185735, -0.12940952255092145];
high_pass_recomp = [-0.12940952255092145, -0.22414386804185735, 0.836516303737469, -0.48296291314469025];

img1 = imread('2.jpg');
img = img1(:,1:512);
[m, n] = size(img)
fprintf(' %f \n', m);
fprintf(' %f \n', n);
row_wise_conv_lp = zeros(512, 515);
for r = 1:512
  row_wise_conv_lp(r, :) = conv(img(r, :), low_pass_decomp);
end

row_wise_downsample_lp = zeros(512, 258);
for r = 1:512
  x = row_wise_conv_lp(r,:);
  row_wise_downsample_lp(r, :) = x(1:2:end);
end

col_wise_conv_ll = zeros(515, 258);
for c = 1:258
  col_wise_conv_ll(:, c) = conv(row_wise_downsample_lp(:, c), low_pass_decomp);
end

col_wise_downsample_ll = zeros(258, 258);
for c = 1:258
  x = col_wise_conv_ll(:, c);
  col_wise_downsample_ll(:, c) = x(1:2:end);
end

ll_band = col_wise_downsample_ll;

col_wise_conv_lh = zeros(515, 258);
for c = 1:258
  col_wise_conv_lh(:, c) = conv(row_wise_downsample_lp(:, c), high_pass_decomp);
end

col_wise_downsample_lh = zeros(258, 258);
for c = 1:258
  x = col_wise_conv_lh(:, c);
  col_wise_downsample_lh(:, c) = x(1:2:end);
end

lh_band = col_wise_downsample_lh;
imshow(img);
figure, imshow(uint8(ll_band));
figure, imshow(uint8(lh_band));



row_wise_conv_hp = zeros(512, 515);
for r = 1:512
  row_wise_conv_hp(r, :) = conv(img(r, :), high_pass_decomp);
end

row_wise_downsample_hp = zeros(512, 258);
for r = 1:512
  x = row_wise_conv_hp(r,:);
  row_wise_downsample_hp(r, :) = x(1:2:end);
end

col_wise_conv_hh = zeros(515, 258);
for c = 1:258
  col_wise_conv_hh(:, c) = conv(row_wise_downsample_hp(:, c), high_pass_decomp);
end

col_wise_downsample_hh = zeros(258, 258);
for c = 1:258
  x = col_wise_conv_hh(:, c);
  col_wise_downsample_hh(:, c) = x(1:2:end);
end
hh_band = col_wise_downsample_hh;

col_wise_conv_hl = zeros(515, 258);
for c = 1:258
  col_wise_conv_hl(:, c) = conv(row_wise_downsample_hp(:, c), low_pass_decomp);
end

col_wise_downsample_hl = zeros(258, 258);
for c = 1:258
  x = col_wise_conv_hl(:, c);
  col_wise_downsample_hl(:, c) = x(1:2:end);
end

hl_band = col_wise_downsample_hl;
figure, imshow(uint8(hl_band));
figure, imshow(uint8(hh_band));

upsampled_ll_for_rec = zeros(516, 258);
for i = 1:258
  upsampled_ll_for_rec(:, i) = upsample(ll_band(:, i), 2);
end
ll_colwise_conv_lp_for_rec = zeros(519, 258);
for i = 1: 258
  ll_colwise_conv_lp_for_rec(:, i) = conv(upsampled_ll_for_rec(:, i), low_pass_recomp);
end
upsampled_lh_for_rec = zeros(516, 258);
for i = 1:258
  upsampled_lh_for_rec(:, i) = upsample(lh_band(:, i),2);
end
lh_colwise_conv_hp_for_rec = zeros(519, 258);
for i = 1: 258
  lh_colwise_conv_hp_for_rec(:, i) = conv(upsampled_lh_for_rec(:, i), high_pass_recomp);
end

comb_ll_lh = ll_colwise_conv_lp_for_rec + lh_colwise_conv_hp_for_rec;

upsampled_hl_for_rec = zeros(516, 258);
for i = 1:258
  upsampled_hl_for_rec(:, i) = upsample(hl_band(:, i),2);
end
hl_colwise_conv_lp_for_rec = zeros(519, 258);
for i = 1: 258
  hl_colwise_conv_lp_for_rec(:, i) = conv(upsampled_hl_for_rec(:, i), low_pass_recomp);
end
upsampled_hh_for_rec = zeros(516, 258);
for i = 1:258
  upsampled_hh_for_rec(:, i) = upsample(hh_band(:, i), 2);
end
hh_colwise_conv_hp_for_rec = zeros(519, 258);
for i = 1: 258
  hh_colwise_conv_hp_for_rec(:, i) = conv(upsampled_hh_for_rec(:, i), high_pass_recomp);
end

comb_hl_hh = hl_colwise_conv_lp_for_rec + hh_colwise_conv_hp_for_rec;

comb_ll_lh_upsampled = zeros(519, 516);
for i=1:518
  comb_ll_lh_upsampled(i, :) = upsample(comb_ll_lh(i, :),2);
end
comb_ll_lh_conv_lp_for_rec= zeros(519, 519);
for i=1:518
  comb_ll_lh_conv_lp_for_rec(i, :) = conv(comb_ll_lh_upsampled(i, :), low_pass_recomp);
end

comb_hl_hh_upsampled = zeros(519, 516);
for i=1:518
  comb_hl_hh_upsampled(i, :) = upsample(comb_hl_hh(i, :),2);
end

comb_hl_hh_conv_hp_for_rec = zeros(519, 519);
for i=1:518
  comb_hl_hh_conv_hp_for_rec(i, :) = conv(comb_hl_hh_upsampled(i, :), high_pass_recomp);
end

rec_img = comb_hl_hh_conv_hp_for_rec + comb_ll_lh_conv_lp_for_rec;
figure, imshow(uint8(rec_img));
