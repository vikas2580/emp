class EmployeesController < ApplicationController
   before_action :set_employee, only: [:show, :update, :destroy]
   def index
    @employees = Employee.all
    render json: @employees
   end

   def create
    @employee = Employee.new(employee_params)

    if @employee.save
      render json: @employee, status: :created
    else
      render json: @employee.errors, status: :unprocessable_entity
    end
  end
   def tax_deduction
    employees = Employee.all
    tax_details = []

    employees.each do |employee|
      total_salary = calculate_total_salary(employee)
      tax_amount = calculate_tax(total_salary)
      cess_amount = calculate_cess(total_salary)

      tax_details << {
        employee_code: employee.employee_id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        yearly_salary: total_salary,
        tax_amount: tax_amount,
        cess_amount: cess_amount
      }
    end

    render json: tax_details
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :doj, :salary, phone_numbers: [])
  end

  def calculate_total_salary(employee)
    monthly_salary = employee.salary
    loss_of_pay_per_day = monthly_salary / 30
    start_date = employee.doj.to_date
    end_date = Date.current
    months_worked = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + 1

    total_salary = monthly_salary * months_worked

    total_salary
  end

  def calculate_tax(total_salary)
    slabs = [250000, 500000, 1000000]

    tax_amount = 0
    remaining_salary = total_salary

    slabs.each do |slab|
      if remaining_salary > 0
        taxable_amount = [remaining_salary, slab].min
        tax_amount += (taxable_amount * 0.05) if slab <= 500000
        tax_amount += (taxable_amount * 0.1) if slab > 500000 && slab <= 1000000
        tax_amount += (taxable_amount * 0.2) if slab > 1000000
        remaining_salary -= taxable_amount
      else
        break
      end
    end

    tax_amount
  end

  def calculate_cess(total_salary)
    threshold_salary = 2500000
    cess_rate = 0.02

    if total_salary > threshold_salary
      excess_amount = total_salary - threshold_salary
      cess_amount = excess_amount * cess_rate
    else
      cess_amount = 0
    end

    cess_amount
  end
end

