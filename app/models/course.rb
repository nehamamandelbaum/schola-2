# frozen_string_literal: true

class Course < ApplicationRecord
  validates :name, presence: true,
                   uniqueness: { scope: :year }
  validates :year, presence: true,
                   numericality: { only_integer: true, greater_than: 2000 }
  validates :starts_on, presence: true
  validates :ends_on, presence: true,
                      comparison: { greater_than: :starts_on }

  has_many :teacher_assignments, dependent: :destroy
  has_many :teachers, through: :teacher_assignments
  has_many :subjects, through: :teacher_assignments

  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments

  has_many :exams, dependent: :destroy

  scope :with_students, ->(year) {select('enrollments.code, 
                                          students.name as student_name, 
                                          students.id as student_id, 
                                          courses.name as course_name, 
                                          courses.year')
                                  .joins(ActiveRecord::Base.sanitize_sql(['inner join enrollments on courses.id = enrollments.course_id and courses.year = ?', year]))
                                  .joins('right join students on students.id = enrollments.student_id')}
end
