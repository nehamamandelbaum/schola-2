# frozen_string_literal: true

class Enrollment < ApplicationRecord
  validates :code, presence: true,
                   uniqueness: true

  belongs_to :student
  belongs_to :course
  has_many :grades, dependent: :destroy, foreign_key: :enrollment_code, inverse_of: :enrollment

  scope :with_code_and_course_name, ->(student_id:, year:) {select('enrollments.code', 'courses.name')
                                                        .joins(:course)
                                                        .where('courses.year = ? and enrollments.student_id = ?', year, student_id)
                                                        .pick(
                                                          :code, :name
                                                        )}
end
