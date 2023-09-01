# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :set_year, only: %i[show index]

  def index
    @students = Course.select('enrollments.code, students.name as student_name, students.id as student_id, courses.name as course_name, courses.year')
                      .joins("inner join enrollments on courses.id = enrollments.course_id and courses.year = #{@year}")
                      .joins('right join students on students.id = enrollments.student_id')
  end

  def show
    @code, @course_name = Enrollment.select('enrollments.code', 'courses.name')
                                    .joins(:course)
                                    .where("courses.year = #{@year} and enrollments.student_id = #{params[:id]}")
                                    .pick(
                                      :code, :name
                                    )

    @grades = Grade.select('subjects.name as subject_name, grades.enrollment_code, avg(grades.value) as value, grades.id, students.name as student_name')
                   .joins(enrollment: :student)
                   .joins(enrollment: :course)
                   .joins(exam: :subject)
                   .where("enrollments.student_id = #{params[:id]} and courses.year = #{@year}")
                   .group('subjects.name, grades.enrollment_code')

    flash.now[:notice] = 'No grades for this year!' if @grades.empty?
  end

  def new
    @student = Student.new
  end

  def edit; end

  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student, notice: I18n.t('flash.student.success.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: I18n.t('flash.student.success.update'), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_url, notice: I18n.t('flash.student.success.destroy'), status: :see_other
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def set_year
    @year = params[:year] || Date.current.year
  end

  def student_params
    params.require(:student).permit(:name, :born_on)
  end
end
