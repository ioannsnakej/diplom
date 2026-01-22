import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app

#test: open main-page
def test_homepage():
    with app.test_client() as client:
        response = client.get('/')
        assert response.status_code == 200
        assert 'text/html' in response.content_type
        print("✅ main-page is ready")

#test: open books-page
'''
def test_books_page():
    with app.test_client() as client:
        response = client.get('/books')
        assert response.status_code == 200
        print("✅ Page /books is ready")
'''

#test: open book creation form
def test_create_form():
    with app.test_client() as client:
        response = client.get('/create')
        assert response.status_code == 200
        print("✅ Book creation form is ready")

def run_all_tests():
    print("=" * 50)
    print("ЗАПУСК ТЕСТОВ ДЛЯ BOOKSTORE-APP")
    print("=" * 50)
    
    tests = [
        test_homepage,
        test_books_page,
        test_create_form,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            test()
            passed += 1
        except Exception as e:
            failed += 1
            print(f"❌ Тест {test.__name__} не прошел: {e}")
    
    print("=" * 50)
    print(f"ИТОГО: {passed} пройдено, {failed} не пройдено")
    
    if failed == 0:
        print("✅ ВСЕ ТЕСТЫ УСПЕШНО ПРОЙДЕНЫ!")
    else:
        print("⚠️  Некоторые тесты не прошли")
    
    return failed == 0

if __name__ == "__main__":
    success = run_all_tests()
    exit(0 if success else 1)