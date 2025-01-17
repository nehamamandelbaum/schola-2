# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'securerandom'

Subject::THEME.each { |subject| Subject.create!(name: subject) }

5.times { |_| FactoryBot.create(:teacher) }

teachers = Teacher.all
subjects = Subject.all

COURSES = (5..9).to_a

# Para 2012:
courses = COURSES.map do |grade|
  { year: 2012, name: "#{grade}º ano", starts_on: '2012-01-01', ends_on: '2012-12-31' }
end

Course.insert_all(courses)

courses2012 = Course.where(year: 2012)

courses2012.each do |course|
  rand(20..40).times do
    course.enrollments.create!(code: SecureRandom.uuid, student: FactoryBot.create(:student))
  end
end

teacher_assignments = courses2012.to_a.product(subjects).map do |course, subject|
  { course_id: course.id, subject_id: subject.id,
    teacher_id: teachers.sample.id }
end

TeacherAssignment.insert_all(teacher_assignments)

exams2012 = courses2012.to_a.product(subjects).map do |course, subject|
  { course_id: course.id, subject_id: subject.id,
    realized_on: FFaker::Time.between(Date.new(2012, 1, 1), Date.new(2012, 12, 31)).to_s }
end

Exam.insert_all(exams2012)

grades2012 = courses2012.flat_map do |course|
  course.enrollments.flat_map do |enrollment|
    course.exams.flat_map do |exam|
      exams = []
      8.times do
        exams.push({ value: rand(0..10), enrollment_code: enrollment.code, exam_id: exam.id })
      end
      exams
    end
  end
end

Grade.insert_all(grades2012)

# Para os outros anos:

(2013..2023).to_a.each do |year|
  # Criando os cursos do ano
  courses = (5..9).to_a.map do |grade|
    { year:, name: "#{grade}º ano", starts_on: "#{year}-01-01", ends_on: "#{year}-12-31" }
  end

  Course.insert_all(courses)

  # Matriculando alunos novos no 5º ano
  rand(20..40).times do
    Course.where(year:, name: '5º ano').first.enrollments.create!(code: SecureRandom.uuid,
                                                                  student: FactoryBot.create(:student))
  end

  # Criando matrícula do curso seguinte para os alunos do 5º ao 8º ano:
  enrollments = (5..8).to_a.flat_map do |grade|
    Course.where(year: year - 1, name: "#{grade}º ano").first.students.map do |student|
      { code: SecureRandom.uuid, student_id: student.id,
        course_id: Course.where(year:, name: "#{grade + 1}º ano").first.id }
    end
  end

  Enrollment.insert_all(enrollments)

  courses = Course.where(year:)

  teacher_assignments = courses.to_a.product(subjects).map do |course, subject|
    { course_id: course.id, subject_id: subject.id,
      teacher_id: teachers.sample.id }
  end

  TeacherAssignment.insert_all(teacher_assignments)

  exams = courses.to_a.product(subjects).map do |course, subject|
    { course_id: course.id, subject_id: subject.id,
      realized_on: FFaker::Time.between(Date.new(2012, 1, 1), Date.new(2012, 12, 31)).to_s }
  end

  Exam.insert_all(exams)

  grades = courses.flat_map do |course|
    course.enrollments.flat_map do |enrollment|
      course.exams.flat_map do |exam|
        grades_hashes = []
        if year == 2023
          4.times do
            grades_hashes.push({ value: rand(0..10), enrollment_code: enrollment.code, exam_id: exam.id })
          end
        else
          8.times do
            grades_hashes.push({ value: rand(0..10), enrollment_code: enrollment.code, exam_id: exam.id })
          end
        end
        grades_hashes
      end
    end
  end

  Grade.insert_all(grades)
end
