require 'gepub'

TEMPLATE_DIRECTORY = Rails.root.join('app/lib/ebook')

class Ebook::EpubGenerator
  include ActionView::Helpers::TagHelper

  def initialize(story)
    @story = story
  end

  def generate
    book = GEPUB::Book.new
    book.add_title @story.title, title_type: GEPUB::TITLE_TYPE::MAIN, lang: :en, display_seq: 1
    book.add_creator @story.author.name
    book.add_item 'styles.css', content: TEMPLATE_DIRECTORY.join('files/styles.css').open

    book.ordered do
      book.add_item('CoverPage.html', content: generate_cover_page).landmark(type: 'cover', title: 'Cover Page')
      @story.chapters.each do |chapter|
        book.add_item("Chapter#{chapter.number}.html", content: generate_chapter(chapter))
            .toc_text("Chapter #{chapter.number} - #{chapter.title}")
            .landmark(type: 'bodymatter', title: chapter.title)
      end
    end

    book
  end

  #private

  def render_template(name, context)
    Slim::Template.new(TEMPLATE_DIRECTORY.join("templates/#{name}.html.slim")).render(context)
  end

  def generate_cover_page
    StringIO.new render_template('cover', @story)
  end

  def generate_chapter(chapter)
    StringIO.new render_template('chapter', chapter)
  end
end
