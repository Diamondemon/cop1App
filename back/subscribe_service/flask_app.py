import app
from selenium import webdriver
import runner
driver = webdriver.Chrome(options=app.set_chrome_options())
flask = runner.main(driver)
