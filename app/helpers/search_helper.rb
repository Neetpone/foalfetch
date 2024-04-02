module SearchHelper
  def rating_display(rating)
    case rating
      when 'everyone' then
        tag.div class: 'frating ev', title: 'Rated Everyone' do
          'Everyone'
        end
    when 'teen' then
      tag.div class: 'frating', title: 'Rated Teen' do
        'Teen'
      end
    when 'explicit' then
      tag.div class: 'frating', title: 'Rated Explicit' do
        'Explicit'
      end
    end
  end

  def status_display(status)
    case status
      when 'complete' then
        tag.div class: 'fstatus sc', title: 'Complete' do
          'Complete'
        end
      when 'incomplete' then
        tag.div class: 'fstatus si', title: 'Incomplete' do
          'Incomplete'
        end
      when 'cancelled' then
        tag.div class: 'fstatus sn', title: 'Cancelled' do
          'Cancelled'
        end
    end
  end

  def tag_to_html(t)
    tag.div class: 'ftag', title: t.name do
      t.name
    end
  end

  def character_display(t)
    tag.div class: 'ftag', title: t.name do
      t.name
    end
  end
end
