# frozen_string_literal: true
module SearchHelper
  def rating_display(rating)
    case rating
      when 'everyone'
        tag.div class: 'frating ev', title: 'Rated Everyone' do
          'Everyone'
        end
      when 'teen'
        tag.div class: 'frating', title: 'Rated Teen' do
          'Teen'
        end
      when 'explicit'
        tag.div class: 'frating', title: 'Rated Explicit' do
          'Explicit'
        end
    end
  end

  def status_display(status)
    case status
      when 'complete'
        tag.div class: 'fstatus sc', title: 'Complete' do
          'Complete'
        end
      when 'incomplete'
        tag.div class: 'fstatus si', title: 'Incomplete' do
          'Incomplete'
        end
      when 'hiatus'
        tag.div class: 'fstatus sh', title: 'On Hiatus' do
          'On Hiatus'
        end
      when 'cancelled'
        tag.div class: 'fstatus sn', title: 'Cancelled' do
          'Cancelled'
        end
    end
  end

  def tag_to_html(t)
    tag.div class: "ftag #{t.name.downcase.gsub(' ', '-')}", title: t.name do
      t.name
    end
  end

  def character_display(t)
    tag.img class: 'character', src: "/img/characters/#{t.image_name}.png", title: t.name, alt: t.name[0]
  end
end
