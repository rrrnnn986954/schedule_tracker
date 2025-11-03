module CategoriesHelper
  COLOR_HEX = {
    "red"=>"#EF4444","orange"=>"#F59E0B","yellow"=>"#EAB308",
    "green"=>"#22C55E","blue"=>"#3B82F6","indigo"=>"#6366F1","purple"=>"#A855F7"
  }.freeze

  def color_hex(category_or_key)
    key = category_or_key.is_a?(Category) ? category_or_key.color : category_or_key.to_s
    COLOR_HEX[key]
  end
end
