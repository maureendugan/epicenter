class Assessment < ActiveRecord::Base
  validates_presence_of :title, :section, :url
  validate :presence_of_requirements

  has_many :requirements
  has_many :submissions

  accepts_nested_attributes_for :requirements, reject_if: :attributes_blank?, allow_destroy: true

  def submission_for(student)
    submissions.find_by(student: student)
  end

private

  def presence_of_requirements
    if requirements.size < 1
      errors.add(:requirements, 'must be present.')
    end
  end

  def attributes_blank?(attributes)
    attributes['content'].blank?
  end
end