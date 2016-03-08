# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

new_row = []
new_freq = []
new_emp = []
new_mail = []
new_cust = []
new_acct = []
invoice_data = []

CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
  new_row << row.to_h[:product_name]
  new_freq << row.to_h[:invoice_frequency]
  employee = row.to_h[:employee]
  customer = row.to_h[:customer_and_account_no]
  invoice_data << row.to_h
  split_employee = employee.split(" (")
  new_emp << split_employee[0]
  new_mail << split_employee[1].gsub(")","")
  split_customer = customer.split(" (")
  new_cust << split_customer[0]
  new_acct << split_customer[1].gsub(")","")
end

puts new_cust.uniq!
puts new_acct.uniq!

new_emp.uniq!
new_mail.uniq!

new_row.uniq!
new_freq.uniq!

new_row.each do |item|
  db_connection do |conn|
    conn.exec_params("INSERT INTO product (product_name) VALUES ($1)", [item])
  end
end

new_freq.each do |item|
  db_connection do |conn|
    conn.exec_params("INSERT INTO frequency (inv_freq) VALUES ($1)", [item])
  end
end

i=0
new_emp.size.times do
  db_connection do |conn|
    conn.exec_params("INSERT INTO employee (name, email) VALUES ($1,$2)", [new_emp[i],new_mail[i]])
    i += 1
  end
end

i=0
new_cust.size.times do
  db_connection do |conn|
    conn.exec_params("INSERT INTO customer (id, name) VALUES ($1,$2)", [new_acct[i],new_cust[i]])
    i += 1
  end
end

invoice_data.each do |row|
  db_connection do |conn|
    prod_id =  conn.exec("SELECT id FROM product WHERE '#{row[:product_name]}'=(product_name)")
    emp_id =  conn.exec("SELECT id FROM employee WHERE (name) LIKE '%#{row[:employee][0...4]}%'")
    cust_id =  conn.exec("SELECT id FROM customer WHERE (name) LIKE '%#{row[:customer_and_account_no][0...2]}%'")
    freq_id =  conn.exec("SELECT id FROM frequency WHERE (inv_freq) LIKE '%#{row[:invoice_frequency][0...4]}%'")
    conn.exec_params("INSERT INTO invoices (product_id,inv_num,sale_amt,date_sold,units_sold,employee_id,customer_id,frequency_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)", [prod_id[0]["id"],row[:invoice_no],row[:sale_amount],row[:sale_date],row[:units_sold],emp_id[0]["id"],cust_id[0]["id"],freq_id[0]["id"]])
  end
end


# SELECT id FROM employee WHERE (name) = blah



# employee,customer_and_account_no,product_name,sale_date,sale_amount,units_sold,invoice_no,invoice_frequency
