require 'mechanize'
require 'pry'

class Ferma
  attr_reader :resources

  def inspect
    @resources
  end

  def initialize(login = 'kadyr.zegarde@mail.ru', password = 'password1234567!')
    @resources = { gold: '', gems: '', fuel: '' }
    @agent = Mechanize.new
    @agent.user_agent = Mechanize::AGENT_ALIASES['Android']

    login_form = @agent.get('http://m.ok.ru/').form
    login_form.checkboxes.first.check
    login_form['fr.login'] = login
    login_form['fr.password'] = password
    login_form.submit

    @ferma_light = @agent.get('https://m.ok.ru/app/mferma?refplace=16&__dp=y')
    @ferma_light = @ferma_light.links.select { |x| x.href == '?wicket:interface=:1:expAndUserPanelContainer:userPanel:footerLinks:toggleLightLink::ILinkListener::'}.first.click
    update_resources(@ferma_light)
    return @resources
  end

  def garden(action = nil)
    case action&.to_sym
    when 'Вскопать'.to_sym
      garden = @ferma_light.link_with(href: 'garden').click
      garden_bed0 = garden.link_with(href: 'garden/bed/0').click
      beds = garden_bed0.links_with(text: 'Вскопать')
      beds.each { |link| link.click }
      update = garden_bed0.link_with(text: 'Обновить').click
      update_garden(0, update)
      garden_bed1 = garden.link_with(href: 'garden/bed/1').click
      beds = garden_bed1.links_with(text: 'Вскопать')
      beds.each { |link| link.click; }
      update = garden_bed1.link_with(text: 'Обновить').click
      update_garden(1, update)
    when 'Посадить'.to_sym
      garden = @ferma_light.link_with(href: 'garden').click
      garden_bed0 = garden.link_with(href: 'garden/bed/0').click
      garden_bed0.links_with(text: /Посадить/).each do |bed_link|
        if bed_link.text == 'Посадить Пшеницу'
          bed_link.click
        else
          # need to debug this
          # binding.pry
          seeds = garden_bed0.link_with(text: 'Посадить').click
          sleep 1
          seeds = seeds.link_with(text: 'Для производства').click
          sleep 1
          seeds = seeds.link_with(text: '<<Назад').click
          sleep 1
          garden_bed0 = seeds.link_with(text: 'Пшеница').click
          sleep 1
        end
      end
      update = garden_bed0.link_with(text: 'Обновить').click
      update_garden(0, update)

      garden_bed1 = garden.link_with(href: 'garden/bed/1').click
      garden_bed1.links_with(text: /Посадить/).each do |bed_link|
        if bed_link.text == 'Посадить Пшеницу'
          bed_link.click
        else
          seeds = garden_bed1.link_with(text: 'Посадить').click
          sleep 1
          seeds = seeds.link_with(text: 'Для производства').click
          sleep 1
          seeds = seeds.link_with(text: '<<Назад').click
          sleep 1
          garden_bed0 = seeds.link_with(text: 'Пшеница').click
          sleep 1
        end
      end
      update = garden_bed1.link_with(text: 'Обновить').click
      update_garden(1, update)
    when 'Полить'.to_sym
      garden = @ferma_light.link_with(href: 'garden').click
      garden_bed0 = garden.link_with(href: 'garden/bed/0').click
      beds = garden_bed0.links_with(text: 'Полить')
      beds.each { |link| link.click }
      update = garden_bed0.link_with(text: 'Обновить').click
      update_garden(0, update)

      garden_bed1 = garden.link_with(href: 'garden/bed/1').click
      beds = garden_bed1.links_with(text: 'Полить')
      beds.each { |link| link.click; }
      update = garden_bed1.link_with(text: 'Обновить').click
      update_garden(1, update)
    when 'Удобрить'.to_sym
      garden = @ferma_light.link_with(href: 'garden').click
      garden_bed0 = garden.link_with(href: 'garden/bed/0').click
      garden_bed0.links_with(text: /Удобрить/).each do |bed_link|
        if bed_link.text == 'Удобрить Азотом'
          bed_link.click
        else
          # need to debug this
          # binding.pry
          ferts = garden_bed0.link_with(text: 'Удобрить').click
          sleep 1
          ferts = ferts.link_with(text: 'Азот').click
          sleep 1
        end
      end
      # move update to it's own private action
      update = garden_bed0.link_with(text: 'Обновить').click
      update_garden(0, update)

      garden_bed1 = garden.link_with(href: 'garden/bed/1').click
      garden_bed1.links_with(text: /Удобрить/).each do |bed_link|
        if bed_link.text == 'Удобрить Азотом'
          bed_link.click
        else
          binding.pry
          ferts = garden_bed1.link_with(text: 'Удобрить').click
          sleep 1
          ferts = ferts.link_with(text: 'Азот').click
          sleep 1
        end
      end
      update = garden_bed1.link_with(text: 'Обновить').click
      update_garden(1, update)
    when 'Собрать'.to_sym
      garden = @ferma_light.link_with(href: 'garden').click
      garden_bed0 = garden.link_with(href: 'garden/bed/0').click
      beds = garden_bed0.links_with(text: 'Собрать')
      beds.each { |link| link.click }
      update = garden_bed0.link_with(text: 'Обновить').click
      update_garden(0, update)

      garden_bed1 = garden.link_with(href: 'garden/bed/1').click
      beds = garden_bed1.links_with(text: 'Собрать')
      beds.each { |link| link.click; }
      update = garden_bed1.link_with(text: 'Обновить').click
      update_garden(1, update)
    else
      @resources[:garden] = []
      @resources[:garden].push([]).push([])
      garden = @ferma_light.link_with(href: 'garden').click
      garden_bed0 = garden.link_with(href: 'garden/bed/0').click
      update_garden(0, garden_bed0)

      garden_bed1 = garden.link_with(href: 'garden/bed/1').click
      update_garden(1, garden_bed0)
    end
    @resources[:garden]
  end

  def logout
    @ferma_light.link_with(text: 'Выйти').click;
  end

  private

  def update_garden(index, page)
    @resources[:garden][index] = []
    page.search('div.bg_lbrown.li').each do |bed|
      action = bed.search('a').text
      status = bed.search('.lbrown.small').text
      @resources[:garden][index].push({ status: status, action: action })
    end
    update_resources(page)
  end

  def update_resources(page)
    page.search('.brown').select { |x| x.attribute('style')&.value == 'text-decoration: none;' }.map(&:text).map(&:split).flatten.each_with_index do |v, index|
      case index
      when 0 then @resources[:gold] = v
      when 1 then @resources[:gems] = v
      when 2 then @resources[:fuel] = v
      end
    end
    @resources
  end

  def garden_single_action(index, page)
    garden = @ferma_light.link_with(href: 'garden').click
    garden_bed = garden.link_with(href: "garden/bed/#{index}").click
    beds = garden_bed.links_with(text: 'Вскопать')
    beds.each { |link| link.click }
    update = garden_bed0.link_with(text: 'Обновить').click
    update_garden(0, update)
    garden_bed1 = garden.link_with(href: 'garden/bed/1').click
    beds = garden_bed1.links_with(text: 'Вскопать')
    beds.each { |link| link.click; }
    update = garden_bed1.link_with(text: 'Обновить').click
    update_garden(1, update)
  end
end
