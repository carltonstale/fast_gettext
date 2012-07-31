class TranslationText < ActiveRecord::Base
  belongs_to :translation_key, :class_name => 'TranslationKey'
  validates_presence_of :locale
  validates_uniqueness_of :locale, :scope=>:translation_key_id
  attr_accessible :text, :locale, :translation_key, :translation_key_id
end
