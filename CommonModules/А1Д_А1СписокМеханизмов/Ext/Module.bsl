﻿Функция ДобавитьМеханизмы(СписокМеханизмов) Экспорт
	СписокМеханизмов.Добавить(А1Э_Механизмы.Создать("А1Д_СвязиОбъектов"));
	СписокМеханизмов.Добавить(А1Э_Механизмы.Создать("А1Д_КаждыеПятьМинутФайловаяБаза"));
КонецФункции

Функция ДобавитьОбъекты(СписокОбъектов) Экспорт
	А1Э_Механизмы.ДобавитьКОбъектам(СписокОбъектов, А1Э_Механизмы.Адресация__БезОбъектов(), "А1Э_ОбновлениеРасширений");
	А1Э_Механизмы.ДобавитьКОбъектам(СписокОбъектов, А1Э_Механизмы.Адресация__БезОбъектов(), "А1Э_РегулярныеПроцессы");
	А1Э_Механизмы.ДобавитьКОбъектам(СписокОбъектов, А1Э_Механизмы.Адресация__БезОбъектов(), "А1Д_КаждыеПятьМинутФайловаяБаза");
КонецФункции