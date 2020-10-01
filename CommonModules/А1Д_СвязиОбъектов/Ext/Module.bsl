﻿#Область Механизм

Функция НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("А1Э_ПриПодключенииКонтекста", Истина);
	Настройки.Обработчики.Вставить("А1Э_ПриПоискеОшибок", Истина);
	Настройки.Обработчики.Вставить("А1Э_ПриИсправленииОшибок", Истина);
	Настройки.Обработчики.Вставить("ПриЗаписи", Истина);
	Настройки.Обработчики.Вставить("ФормаПриСозданииНаСервере", Истина);
	
	Настройки.ПорядокВыполнения = 1000;
	
	Возврат Настройки;
КонецФункции

#Область А1Э_ПриПодключенииКонтекста

// Выполняется при подключении контекста 
//
// Параметры:
//  ТекущийКонтекст	 - Массив - должен в итоге содержать ЭлементыКонтекста(структуры с ключами Поле (имя реквизита или ТЧ), Колонка, Вид).
//  НовыйКонтекст	 - Строка,Массив,Булево - содержит ЭлементыКонтекста, Строки или Истина (эквивалентно пустому массиву). 
// 
// Возвращаемое значение:
//   - 
//
Функция А1Э_ПриПодключенииКонтекста(ТекущийКонтекст, НовыйКонтекст) Экспорт 
	Если ТекущийКонтекст = Неопределено Тогда ТекущийКонтекст = Новый Массив; КонецЕсли;
	Если НовыйКонтекст = Истина Тогда Возврат Неопределено; КонецЕсли;
	
	МассивНовогоКонтекста = А1Э_Массивы.Массив(НовыйКонтекст);
	Для Каждого Элемент Из МассивНовогоКонтекста Цикл
		ЭлементКонтекста = Новый Структура("Поле,Колонка,Вид");
		ТекущийКонтекст.Добавить(ЭлементКонтекста);
		
		Если ТипЗнч(Элемент) = Тип("Структура") Тогда
			ЗаполнитьЗначенияСвойств(ЭлементКонтекста, Элемент);
		ИначеЕсли ТипЗнч(Элемент) = Тип("Строка") Тогда
			РазобратьСтрокуКонтекста(Элемент, ЭлементКонтекста);
		Иначе
			А1Э_Служебный.СлужебноеИсключение("Неверный тип элемента контекста механизма А1Д_СвязиОбъектов - ожидается Строка или Структура");
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(ЭлементКонтекста.Поле) Тогда
			А1Э_Служебный.СлужебноеИсключение("Не удалось определить поле в механизме А1Д_СвязиОбъектов!");
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(ЭлементКонтекста.Вид) Тогда
			ЭлементКонтекста.Вид = "Предок";
		ИначеЕсли ЭлементКонтекста.Вид <> "Предок" И ЭлементКонтекста.Вид <> "Потомок" Тогда
			А1Э_Служебный.СлужебноеИсключение("Неверный вид элемента контекста механизма А1Д_СвязиОбъектов - ожидается ""Родитель"" или ""Потомок""");
		КонецЕсли;
	КонецЦикла;
КонецФункции

Функция РазобратьСтрокуКонтекста(Строка, ЭлементКонтекста)
	ЧастиСтроки = А1Э_Строки.ПередПосле(Строка, ":");
	Если НЕ ЗначениеЗаполнено(ЧастиСтроки.После) Тогда
		ЭлементКонтекста.Вид = "Предок";
	Иначе
		ЭлементКонтекста.Вид = ЧастиСтроки.После;
	КонецЕсли;
	ЧастиПоля = А1Э_Строки.ПередПосле(ЧастиСтроки.Перед, ".");
	ЭлементКонтекста.Поле = ЧастиПоля.Перед;
	ЭлементКонтекста.Колонка = ЧастиПоля.После;
КонецФункции

#КонецОбласти 

#Если НЕ Клиент Тогда
	#Область ПоискОшибок
	
	Функция А1Э_ПриПоискеОшибок(Ошибки) Экспорт
		ОбъектыМеханизма = А1Э_Механизмы.ОбъектыМеханизма(ИмяМодуля());
		Для Каждого Пара Из ОбъектыМеханизма Цикл
			ИмяОбъекта = Пара.Ключ;
			ЭлементыКонтекста = Пара.Значение;
			Если ЭлементыКонтекста.Количество() = 0 Тогда Продолжить; КонецЕсли;
			
			КодОбъекта = А1Э_Метаданные.КодПоПолномуИмени(ИмяОбъекта);
			Запрос = Новый Запрос;
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	СвязиОбъектов.Источник КАК Источник,
			|	СвязиОбъектов.Предок КАК Предок,
			|	СвязиОбъектов.Потомок КАК Потомок
			|ИЗ
			|	РегистрСведений.А1Д_СвязиОбъектов КАК СвязиОбъектов
			|ГДЕ
			|	ПОДСТРОКА(СвязиОбъектов.Источник, 1, &ДлинаКода) = &Код";
			Запрос.УстановитьПараметр("ДлинаКода", СтрДлина(КодОбъекта) + 1);
			Запрос.УстановитьПараметр("Код", КодОбъекта + ":");
			ТаблицаСвязей = Запрос.Выполнить().Выгрузить();
			Запрос.Текст = ТекстЗапросаПравильныхСвязей(ИмяОбъекта, ЭлементыКонтекста);
			ТаблицаПравильныхСвязейЗапрос = Запрос.Выполнить().Выгрузить();
			ТаблицаНужныхСвязей = ТаблицаСвязей.СкопироватьКолонки(); 
			Для Каждого Строка Из ТаблицаПравильныхСвязейЗапрос Цикл
				СтрокаНужныхСвязей = ТаблицаНужныхСвязей.Добавить();
				СтрокаНужныхСвязей.Источник = А1Э_Метаданные.ИдентификаторПоСсылке(Строка.Источник);
				СтрокаНужныхСвязей.Предок = А1Э_Метаданные.ИдентификаторПоСсылке(Строка.Предок);
				СтрокаНужныхСвязей.Потомок = А1Э_Метаданные.ИдентификаторПоСсылке(Строка.Потомок);
			КонецЦикла;
			ТаблицаСвязей.Сортировать("Источник,Предок,Потомок");
			ТаблицаНужныхСвязей.Сортировать("Источник,Предок,Потомок");
			СоответствиеСвязей = А1Э_ТаблицыЗначений.РазбитьПоКолонке(ТаблицаСвязей, "Источник");
			СоответствиеНужныхСвязей = А1Э_ТаблицыЗначений.РазбитьПоКолонке(ТаблицаНужныхСвязей, "Источник");
			Для Каждого Пара Из СоответствиеСвязей Цикл
				Связи = Пара.Значение;
				НужныеСвязи = СоответствиеНужныхСвязей[Пара.Ключ];
				Если НужныеСвязи = Неопределено Тогда
					А1Э_Механизмы.ДобавитьОписаниеОшибки(Ошибки, "РазличныеСвязи", ИмяОбъекта, А1Э_Метаданные.СсылкаПоИдентификатору(Пара.Ключ), "Связи в базе данных отличаются от расчетных!", Истина);
					Продолжить;
				КонецЕсли;
				Если Связи.Количество() <> НужныеСвязи.Количество() Тогда
					А1Э_Механизмы.ДобавитьОписаниеОшибки(Ошибки, "РазличныеСвязи", ИмяОбъекта, А1Э_Метаданные.СсылкаПоИдентификатору(Пара.Ключ), "Связи в базе данных отличаются от расчетных!", Истина);
					СоответствиеНужныхСвязей.Удалить(Пара.Ключ);
					Продолжить;
				КонецЕсли;
				Для Сч = 0 По Связи.Количество() - 1 Цикл
					Если Связи[Сч].Предок <> НужныеСвязи[Сч].Предок Или Связи[Сч].Потомок <> НужныеСвязи[Сч].Потомок Тогда
						А1Э_Механизмы.ДобавитьОписаниеОшибки(Ошибки, "РазличныеСвязи", ИмяОбъекта, А1Э_Метаданные.СсылкаПоИдентификатору(Пара.Ключ), "Связи в базе данных отличаются от расчетных!", Истина);
						СоответствиеНужныхСвязей.Удалить(Пара.Ключ);
						Продолжить;
					КонецЕсли;
				КонецЦикла;
				СоответствиеНужныхСвязей.Удалить(Пара.Ключ);
			КонецЦикла;
			Для Каждого Пара Из СоответствиеНужныхСвязей Цикл
				А1Э_Механизмы.ДобавитьОписаниеОшибки(Ошибки, "РазличныеСвязи", ИмяОбъекта, А1Э_Метаданные.СсылкаПоИдентификатору(Пара.Ключ), "Связи в базе данных отличаются от расчетных!", Истина);
			КонецЦикла;
		КонецЦикла;
		
	КонецФункции
	
	Функция ТекстЗапросаПравильныхСвязей(ИмяМетаданных, ЭлементыКонтекста)
		МассивЧастей = Новый Массив;
		Шаблон =
		"ВЫБРАТЬ
		|	А1_Таблица.Ссылка КАК Источник,
		|	&Предок КАК Предок,
		|	&Потомок КАК Потомок
		|ИЗ
		|	А1_ТаблицаМетаданных КАК А1_Таблица
		|ГДЕ
		|	&Условие";
		МетаданныеОбъекта = А1Э_Метаданные.ОбъектМетаданных(ИмяМетаданных);
		Для Каждого ЭлементКонтекста Из ЭлементыКонтекста Цикл
			Фрагмент = Шаблон;
			Если НЕ ЗначениеЗаполнено(ЭлементКонтекста.Колонка) Тогда
				ИмяТаблицыМетаданных = ИмяМетаданных;
				ИмяПоля = ЭлементКонтекста.Поле;
				ОписаниеТипов = А1Э_Метаданные.ОписаниеТипаПоля(МетаданныеОбъекта, ИмяПоля); 
			Иначе
				ИмяТаблицыМетаданных = ИмяМетаданных + "." + ЭлементКонтекста.Поле;
				ИмяПоля = ЭлементКонтекста.Колонка;
				ОписаниеТипов = МетаданныеОбъекта.ТабличныеЧасти[ЭлементКонтекста.Поле].Реквизиты[ИмяПоля].Тип;
			КонецЕсли;
			ИмяПоляЗапроса = "А1_Таблица." + ИмяПоля;
			Если ЭлементКонтекста.Вид = "Предок" Тогда
				Предок = ИмяПоляЗапроса;
				Потомок = "А1_Таблица.Ссылка";
			Иначе
				Предок = "А1_Таблица.Ссылка";
				Потомок = ИмяПоляЗапроса;
			КонецЕсли;
			Условие = "&ИмяПоляЗапроса <> """" И &ИмяПоляЗапроса <> НЕОПРЕДЕЛЕНО";
			Типы = ОписаниеТипов.Типы();
			Если Типы.Количество() > 1 Или Типы[0] <> Тип("Строка") Тогда
				Условие = Условие + " И (ТИПЗНАЧЕНИЯ(&ИмяПоляЗапроса) <> ТИП(Строка) И &ИмяПоляЗапроса <> НЕОПРЕДЕЛЕНО И НЕ &ИмяПоляЗапроса.Ссылка ЕСТЬ NULL)";
			КонецЕсли;
			А1Э_Строки.Подставить(Условие, "&ИмяПоляЗапроса", ИмяПоляЗапроса);
			А1Э_Строки.Подставить(Фрагмент, "А1_ТаблицаМетаданных", ИмяТаблицыМетаданных);
			А1Э_Строки.Подставить(Фрагмент, "&Предок", Предок);
			А1Э_Строки.Подставить(Фрагмент, "&Потомок", Потомок);
			А1Э_Строки.Подставить(Фрагмент, "&Условие", Условие);
			МассивЧастей.Добавить(Фрагмент);
		КонецЦикла;
		Возврат А1Э_Запросы.Объединить(МассивЧастей); 
	КонецФункции
	
	Функция А1Э_ПриИсправленииОшибок(Ошибки) Экспорт 
		НачатьТранзакцию();
		Для Каждого Ошибка Из Ошибки Цикл
			ПриЗаписи(Ошибка.Ссылка, Ложь);
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	КонецФункции
	
	#КонецОбласти 
	
	Функция ПриЗаписи(Объект, Отказ) Экспорт
		Контекст = А1Э_Механизмы.КонтекстМеханизма(Объект, "А1Д_СвязиОбъектов");
		Если Контекст = Истина Тогда Возврат Неопределено; КонецЕсли;
		//РабочийКонтекст = Новый Массив;
		ДанныеДляЗаписи = А1Э_Структуры.Создать(
		"Предок", Новый Массив,
		"Потомок", Новый Массив,
		);
		Если Контекст.Количество() = 0 Тогда Возврат Неопределено; КонецЕсли;
		
		Для Каждого ЭлементКонтекста Из Контекст Цикл
			ПриемникДанных = ДанныеДляЗаписи[ЭлементКонтекста.Вид]; 
			Если НЕ ЗначениеЗаполнено(ЭлементКонтекста.Колонка) Тогда
				А1Э_Массивы.ДобавитьНепустой(ПриемникДанных, Объект[ЭлементКонтекста.Поле]);
			Иначе
				Для Каждого Строка Из Объект[ЭлементКонтекста.Поле] Цикл
					А1Э_Массивы.ДобавитьНепустой(ПриемникДанных, Строка[ЭлементКонтекста.Колонка]);	
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
		А1Э_Массивы.Свернуть(ДанныеДляЗаписи.Предок);
		А1Э_Массивы.Свернуть(ДанныеДляЗаписи.Потомок);
		
		УстановитьПривилегированныйРежим(Истина);
		ИдентификаторОбъекта = А1Э_Метаданные.ИдентификаторПоСсылке(Объект.Ссылка);
		НаборЗаписей = РегистрыСведений.А1Д_СвязиОбъектов.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Источник.Установить(ИдентификаторОбъекта);
		Для Каждого Потомок Из ДанныеДляЗаписи.Потомок Цикл
			ДобавитьЗапись(НаборЗаписей, ИдентификаторОбъекта, ИдентификаторОбъекта, Потомок);	
		КонецЦикла;
		Для Каждого Предок Из ДанныеДляЗаписи.Предок Цикл
			ДобавитьЗапись(НаборЗаписей, ИдентификаторОбъекта, Предок, ИдентификаторОбъекта);
		КонецЦикла;
		НаборЗаписей.Записать(Истина);
		УстановитьПривилегированныйРежим(Ложь);
	КонецФункции
	
	Функция ДобавитьЗапись(НаборЗаписей, Источник, Предок, Потомок) 
		Запись = НаборЗаписей.Добавить();
		Запись.Источник = А1Э_Метаданные.ИдентификаторПоСсылке(Источник);
		Запись.Предок = А1Э_Метаданные.ИдентификаторПоСсылке(Предок);
		Запись.Потомок = А1Э_Метаданные.ИдентификаторПоСсылке(Потомок);
		Возврат Запись;
	КонецФункции
	
	Функция ФормаПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
		Если А1Э_Формы.ТипФормы(Форма) <> "ФормаЭлемента" Тогда Возврат Неопределено; КонецЕсли;
		МассивОписаний = Новый Массив;
		А1Э_Формы.ДобавитьОписаниеКомандыИКнопки(МассивОписаний, "А1Д_ИерархияОбъектов", ИмяМодуля() + ".ОткрытьФормуИерархии", , "Иерархия", Форма.КоманднаяПанель, , "Структура подчиненности",
		А1Э_Структуры.Создать(
		"Картинка", БиблиотекаКартинок.А1Д_СтруктураПодчиненности,
		"Отображение", ОтображениеКнопки.Картинка,
		));
		А1Э_УниверсальнаяФорма.ДобавитьРеквизитыИЭлементы(Форма, МассивОписаний);	
	КонецФункции 
	
#КонецЕсли
#КонецОбласти 

#Область ФормаИерархии
#Если Клиент Тогда
	
	Функция ОткрытьФормуИерархии(Форма, Команда) Экспорт
		Если НЕ ЗначениеЗаполнено(Форма.Объект.Ссылка) Тогда
			Сообщить("Просмотр иерархии возможен только после записи формы!");
		КонецЕсли;
		А1Э_УниверсальнаяФорма.Открыть("Структура подчиненности", ИмяМодуля() + ".ФормаИерархииПриСозданииНаСервере", А1Э_Структуры.Создать(
		"Ссылка", Форма.Объект.Ссылка,
		));
	КонецФункции
	
	Функция ФормаИерархииИерархияПриОткрытии(ИмяКомпонента, Форма, Отказ) Экспорт 
		Для Каждого Строка Из Форма.Иерархия.ПолучитьЭлементы() Цикл 
			ИдентификаторСтроки = Строка.ПолучитьИдентификатор();
			Форма.Элементы.Иерархия.Развернуть(ИдентификаторСтроки, Истина);
		КонецЦикла
	КонецФункции
	
	Функция ФормаИерархииИерархияВыбор(Форма, Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка) Экспорт
		ПоказатьЗначение(, Форма.Элементы.Иерархия.ТекущиеДанные.Элемент);
	КонецФункции 
#КонецЕсли
#Если НЕ Клиент Тогда
	
	Функция ФормаИерархииПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
		Ссылка = Форма.Параметры.Ссылка;
		Форма.ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Нет;
		МассивОписаний = Новый Массив;
		А1Э_Формы.ДобавитьОписаниеДереваФормы(МассивОписаний, "Иерархия", "Элемент", , , ,
		А1Э_Структуры.Создать(
		"ТолькоПросмотр", Истина,
		"ПоложениеКоманднойПанели", ПоложениеКоманднойПанелиЭлементаФормы.Нет,
		),
		А1Э_Структуры.Создать(
		"ФормаПриОткрытии", ИмяМодуля() + ".ФормаИерархииИерархияПриОткрытии",
		"Выбор", ИмяМодуля() + ".ФормаИерархииИерархияВыбор",
		));
		А1Э_УниверсальнаяФорма.ДобавитьРеквизитыИЭлементы(Форма, МассивОписаний);
		Форма.Элементы.Иерархия.ТолькоПросмотр = Истина;
		ДеревоИерархии = ДеревоИерархии(Ссылка);
		ЗначениеВДанныеФормы(ДеревоИерархии, Форма.Иерархия);
	КонецФункции 
	
#КонецЕсли
#КонецОбласти 

#Если НЕ Клиент Тогда
	
	Функция ДеревоИерархии(Ссылка)
		Результат = Новый ДеревоЗначений;
		Результат.Колонки.Добавить("Элемент");
		Корень = Результат;
		
		ПредкиИПотомки = ПредкиИПотомки(Ссылка);
		Для Каждого Предок Из ПредкиИПотомки.Предки Цикл
			Строка = Корень.Строки.Добавить();
			Строка.Элемент = Предок;
			Корень = Строка;
		КонецЦикла;
		ДобавитьПотомковРекурсивно(Корень, ПредкиИПотомки.Потомки);
		ЗаменитьИдентификаторыНаСсылкиРекурсивно(Результат);
		
		Возврат Результат;
	КонецФункции
	
	Функция ЗаменитьИдентификаторыНаСсылкиРекурсивно(Корень)
		Для Каждого Строка Из Корень.Строки Цикл
			Строка.Элемент = А1Э_Метаданные.СсылкаПоИдентификатору(Строка.Элемент);
			ЗаменитьИдентификаторыНаСсылкиРекурсивно(Строка);
		КонецЦикла;
	КонецФункции
	
	Функция ДобавитьПотомковРекурсивно(Корень, Потомки)
		Для Каждого Пара Из Потомки Цикл
			Строка = Корень.Строки.Добавить();
			Строка.Элемент = Пара.Ключ;
			ДобавитьПотомковРекурсивно(Строка, Пара.Значение);
		КонецЦикла;
	КонецФункции
	
	Функция ПредкиИПотомки(Ссылка) 
		ИдентификаторСсылки = А1Э_Метаданные.ИдентификаторПоСсылке(Ссылка);
		Возврат А1Э_Структуры.Создать(
		"Предки", ОднозначныеПредки(ИдентификаторСсылки),
		"Потомки", Потомки(ИдентификаторСсылки),
		);
	КонецФункции
	
	Функция ОднозначныеПредки(ИдентификаторСсылки)
		Результат = Новый Массив;
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Связи.Предок КАК Предок
		|ИЗ
		|	РегистрСведений.А1Д_СвязиОбъектов КАК Связи
		|ГДЕ
		|	Связи.Потомок = &Потомок";
		Запрос.УстановитьПараметр("Потомок", ИдентификаторСсылки);
		Для Сч = 0 По 10 Цикл
			Предки = Запрос.Выполнить().Выгрузить();
			Если Предки.Количество() = 0 Тогда Прервать; КонецЕсли;
			Если Предки.Количество() > 1 Тогда 
				//ТУДУ - сделать обработку нескольких предков.
				Прервать; 
			КонецЕсли;
			Предок = Предки[0].Предок;
			Результат.Вставить(0, Предок);
			Запрос.УстановитьПараметр("Потомок", Предок);
		КонецЦикла;
		
		Возврат Результат;
	КонецФункции
	
	Функция Потомки(ИдентификаторСсылки)
		Результат = Новый Соответствие;
		Результат.Вставить(ИдентификаторСсылки, Новый Соответствие);
		Предки = А1Э_Массивы.Создать(ИдентификаторСсылки);
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Связи.Предок КАК Предок,
		|	Связи.Потомок КАК Потомок
		|ИЗ
		|	РегистрСведений.А1Д_СвязиОбъектов КАК Связи
		|ГДЕ
		|	Связи.Предок В(&Предки)";
		Запрос.УстановитьПараметр("Предки", Предки);
		
		ПрошлыйУровень = Новый Массив;
		НовыйУровень = Новый Массив;
		Для Каждого Пара Из Результат Цикл
			ПрошлыйУровень.Добавить(Пара);
		КонецЦикла;
		
		Для Сч = 0 По 10 Цикл
			Потомки = Запрос.Выполнить().Выгрузить();
			Если Потомки.Количество() = 0 Тогда Прервать; КонецЕсли;
			Предки.Очистить();
			Для Каждого Строка Из Потомки Цикл
				Предки.Добавить(Строка.Потомок);
				Для Каждого Пара Из ПрошлыйУровень Цикл
					Если Пара.Ключ = Строка.Предок Тогда
						Пара.Значение.Вставить(Строка.Потомок, Новый Соответствие);
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			Запрос.УстановитьПараметр("Предки", Предки);
			НовыйУровень.Очистить();
			Для Каждого ПараПрошлогоУровня Из ПрошлыйУровень Цикл
				Для Каждого Пара Из ПараПрошлогоУровня.Значение Цикл
					НовыйУровень.Добавить(Пара);
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
		
		Возврат Результат;
	КонецФункции
	
	Функция ТекстЗапросаВсеСвязи(МаксимальнаяДлинаПути) Экспорт
		Пролог = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Связи.Предок КАК НачалоДуги,
		|	Связи.Потомок КАК КонецДуги,
		|	1 КАК ДлинаДуги
		|ПОМЕСТИТЬ ЗамыканияДлины1
		|ИЗ
		|	РегистрСведений.А1Д_СвязиОбъектов КАК Связи
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Связи.Предок,
		|	Связи.Предок,
		|	0
		|ИЗ
		|	РегистрСведений.А1Д_СвязиОбъектов КАК Связи
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Связи.Потомок,
		|	Связи.Потомок,
		|	0
		|ИЗ
		|	РегистрСведений.А1Д_СвязиОбъектов КАК Связи";
		Рефрен = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
		|	ВтораяДуга.КонецДуги КАК КонецДуги,
		|	ПерваяДуга.ДлинаДуги + ВтораяДуга.ДлинаДуги КАК ДлинаДуги
		|ПОМЕСТИТЬ ЗамыканияДлины#2
		|ИЗ
		|	ЗамыканияДлины#1 КАК ПерваяДуга
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины#1 КАК ВтораяДуга
		|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ЗамыканияДлины#1";
		Эпилог = 
		"ВЫБРАТЬ
		|	Таблица.НачалоДуги КАК Предок,
		|	Таблица.КонецДуги КАК Потомок,
		|	Таблица.ДлинаДуги КАК ДлинаДуги
		|ПОМЕСТИТЬ ВсеСвязиОбъектов
		|ИЗ
		|	ЗамыканияДлины#2 КАК Таблица
		|ГДЕ
		|	Таблица.НачалоДуги <> Таблица.КонецДуги";
		МассивЧастей = Новый Массив;
		МассивЧастей.Добавить(Пролог);
		
		МаксимальнаяДлинаЗамыканий = 1;
		Пока МаксимальнаяДлинаЗамыканий < МаксимальнаяДлинаПути Цикл
			МассивЧастей.Добавить(СтрЗаменить(СтрЗаменить(Рефрен, "#1", Формат(МаксимальнаяДлинаЗамыканий, "ЧГ=0")), "#2", Формат(2 * МаксимальнаяДлинаЗамыканий, "ЧГ=0")));
			МаксимальнаяДлинаЗамыканий = 2 * МаксимальнаяДлинаЗамыканий;
		КонецЦикла;
		
		МассивЧастей.Добавить(СтрЗаменить(Эпилог, "#2", Формат(МаксимальнаяДлинаЗамыканий, "ЧГ=0")));
		Возврат А1Э_Запросы.Соединить(МассивЧастей);
	КонецФункции 
	
#КонецЕсли

Функция ИмяМодуля() Экспорт
	Возврат "А1Д_СвязиОбъектов";
КонецФункции 