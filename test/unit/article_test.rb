#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
 

     def test_no_save
      article = Article.new
      assert !article.save
  end

    def test_no_text
      article = Article.new(:text=>"xxx")
      assert !article.save
  end

    def test_no_title
      article = Article.new(:title=>"xxx")
      assert !article.save
  end

    def test_save
      article = Article.new(:title=>"xxx",:text=>"sdfsdf")
      assert article.save
  end

   def test_save
      article = Article.new(:title=>"xxx",:text=>"sdfsdf")
      article.save
      assert article.destroy
  end





end
