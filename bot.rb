require 'mechanize'
require 'pry'

agent = Mechanize.new
agent.user_agent = Mechanize::AGENT_ALIASES['Android']

ok_ru = agent.get('http://m.ok.ru/')

login = ok_ru.form
login.checkboxes.first.check
login['fr.login'] = 'kadyr.zegarde@mail.ru'
login['fr.password'] = 'password1234567!'
login.submit

ferma_light = agent.get('https://m.ok.ru/app/mferma?refplace=16&__dp=y').links.select { |x| x.href == '?wicket:interface=:1:expAndUserPanelContainer:userPanel:footerLinks:toggleLightLink::ILinkListener::'}.first.click

resources = { gold: '', gems: '', fuel: '' }
ferma_light.search('.brown').select { |x| x.attribute('style')&.value == 'text-decoration: none;' }.map(&:text).map(&:split).flatten.each_with_index do |v, index|
  case index
  when 0 then resources[:gold] = v
  when 1 then resources[:gems] = v
  when 2 then resources[:fuel] = v
  end
end # fills resources with data on gold, gems and fuel

garden = ferma_light.link_with(href: 'garden').click
garden_bed0 = garden.link_with(href: 'garden/bed/0').click



puts "Gold:\n#{gold}"
puts "Gems:\n#{gems}"
puts "Fuel:\n#{fuel}"

garden.link_with(text: 'Выйти').click.link_with(text: 'Выход').click

# garden_bed1 =
