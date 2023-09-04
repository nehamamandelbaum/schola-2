# frozen_string_literal: true

class Grade < ApplicationRecord
  validates :value, presence: true,
                    numericality: { in: 0.0..10.0 }

  belongs_to :exam
  belongs_to :enrollment, foreign_key: :enrollment_code, inverse_of: :grades

  scope :average_per_student_and_year, ->(student_id:, year:) {select('subjects.name as subject_name, grades.enrollment_code, avg(grades.value) as value, grades.id, students.name as student_name')
                                                              .joins(enrollment: :student)
                                                              .joins(enrollment: :course)
                                                              .joins(exam: :subject)
                                                              .where('enrollments.student_id = ? and courses.year = ?', student_id, year)
                                                              .group('subjects.name, grades.enrollment_code')}
end
