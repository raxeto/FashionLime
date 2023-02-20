namespace :seed do
  desc "Seeds the DB with products."
  task :products => "setup:fashionlime" do
    p = Product.first
    ['прост', 'спанак', 'велик', 'як', 'слаб'].each do |first|
      ['сив', 'син', 'черен', 'бял', 'зелен'].each do |col|
        ['риза', 'патка', 'стол', 'маса', 'котка'].each do |thing|
          params = p.as_json

          params[:size_ids] = [p.product_sizes[0].size_id]
          params[:color_ids] = [p.product_colors[0].color_id]
          params.delete('id')

          params['name'] = first + ' ' + col + ' ' + thing
          np = Product.create(params)
        end
      end
    end
  end
end
