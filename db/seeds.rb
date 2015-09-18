if defined?(Refinery::User)
  Refinery::User.all.each do |user|
    if user.plugins.where(:name => 'refinerycms_elasticsearch').blank?
      user.plugins.create(:name => 'refinerycms_elasticsearch')
    end
  end
end

if defined?(Refinery::Page) and !Refinery::Page.exists?(link_url: (url = Refinery::Elasticsearch.page_url))
  page = Refinery::Page.create(
    :title => "Search Results",
    :show_in_menu => false,
    :link_url => url,
    :deletable => false,
    :menu_match => "^#{url}?(\/|\/.+?|)$"
  )

  Refinery::Pages.default_parts.each do |default_page_part|
    page.parts.create(:title => default_page_part, :body => nil)
  end
end
