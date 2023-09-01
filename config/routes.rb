# frozen_string_literal: true

Rails.application.routes.draw do
  resource :dashboard, only: :show

  resources :students

  get '/students/:year', to: 'students#index'
  get '/students/:id/:year', to: 'students#show'

  resources :enrollments, param: :code
  resources :grades
  resources :teachers
  resources :teacher_assignments
  resources :courses
  resources :exams
  resources :subjects

  root 'dashboard#show'
end
