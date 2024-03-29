/*use ile çalışacağımız database 'i belirtiriz.*/
use LibProject 

/*Bu sorgu sayesinde kitap adı K harfiyle başlayan kitapların hangi yazara ait olduğunu sorgularız*/ 
	SELECT w.writerName,a.bookName FROM writers AS w
        INNER JOIN allbooks AS a on w.ID=a.writerID 
        WHERE a.bookName LIKE 'K%' 
        


	/* Bu sorgu sayesinde 2018 tarihinden sonra basılan kitapların basım tarihlerini ve stok tipilerini görürüz.*/
	SELECT a.addedDate,s.stockTypeName FROM allbooks AS a
	INNER JOIN stockType AS s on a.stockTypeID=s.ID
	WHERE a.addedDate > '2018-12-30'


	/*Bu sorgu sayesinde 2018 yıllından önce kaç adet bağışlanan, kaç adet satın alınan kitap olduğunu gördüğümüz sorgudur.*/
	SELECT COUNT(s.stockTypeName) AS AdetSayisi ,s.stockTypeName  FROM allbooks AS a
	JOIN stockType AS s on a.stockTypeID=s.ID
	WHERE a.addedDate < '2018-12-30' GROUP BY s.stockTypeName


	/*Bu sorgu sayesinde yazarların isimlerin de kısaltma kullanan toplam kaç kişi vardır belirleriz.*/
	SELECT COUNT(writerName) AS Adet  FROM writers
	WHERE writerName LIKE '%.%' 

	/*Bu sorgu sayesinde yazarların isimlerin de kısaltma kullananların isimlerini belirleriz.*/
    SELECT writerName FROM writers
	WHERE writerName LIKE '%.%' GROUP BY writerName

	/*Stored Procedure yardımıyla bir fonksiyon oluşturduk.
	allBooks tablosundaki yazarların tabloda kaç adet kitapları var 
	ve tabloda bulunan kitap türlerinden kaçar adet var hesaplanır.
	 */

	use LibProject
	go
	ALTER PROCEDURE Hesapla 
	AS
	BEGIN

	    SELECT COUNT(writerName) AS 'Adet Sayisi',writerName FROM allbooks GROUP BY writerName

		  SELECT COUNT(bookTypeName) AS 'Adet Sayisi',bookTypeName FROM allbooks GROUP BY bookTypeName
	END

	execute Hesapla


	/*Stored Procedure yardımıyla bir fonksiyon oluşturduk. 
	allbooks tablosunda her türde yazarların kaçar adet kitabının olduğunu sorgululamamızı sağlayan sorgudur.*/
	
	go
	ALTER PROCEDURE yazarTurIliskisi
	AS
	BEGIN

		SELECT COUNT(a.writerName) AS 'Yazar Adet Sayısı',a.writerName, a.bookTypeName
		FROM allbooks AS a
		GROUP BY a.writerName ,a.bookTypeName
		
	END

	execute yazarTurIliskisi

	/* publisher tablosunda publisherName kolonunda Yayınları yazan yerler Yayınevi olarak değiştirmemizi sağlayan sorgudur.*/
	
	go
	ALTER PROCEDURE degistir
	AS
	BEGIN

	  select *,
	  CASE 
	   when publisherName like '%Yayınları%' then 'Yayinevi' 
	   else
		publisherName
	    end
	   FROM publisher

	END

	execute degistir

	

	/* allBooks tablosuna en eski basılan 5 kitabı en eski tarihten en yeni basılana doğru sıralı olarak sorgular. Bu işlemi ASC kullanarakta alabiliriz.*/
	Select  top 5 a.addedDate, a.bookName FROM allbooks AS a ORDER BY a.addedDate

   /* allBooks tablosunda en eski basım olan 5 kitabı en eski tarihten en yeni basılana doğru sıralı olarak sorgulamamızı sağlar.*/
	Select  top 5 a.addedDate, a.bookName FROM allbooks AS a ORDER BY a.addedDate ASC

   /*Yukardaki iki sorgunun aynı sonucu vermesinin nedeni ORDER BY varsayılan olarak ASC sıralamasında çalışır.*/

	/* allBooks tablosuna en son basılan 5 kitabı en yakın tarihten en eskisine doğru sıralı olarak sorgular.*/
	Select  top 5 a.addedDate, a.bookName FROM allbooks AS a ORDER BY a.addedDate DESC


	


	/*bookTypeName tablosunda ID numarası tek ve çift olanları aynı tabloda önce tek olanlar sonra çift olanlar şeklinde sıralayan sorgudur.*/
	  select * from bookTypeName where ID % 2 = 1
    union all
    select *  from bookTypeName where ID % 2 = 0


	/*Publisher ve allbooks tablosunda ID değerleri çift olan publisherName ve bookName'leri sorgulayaran ve ID'leriyle çıktı veren sorgudur.*/
	  SELECT  p.ID, p.publisherName,a.ID,a.bookName FROM allbooks AS a
	  INNER JOIN publisher AS p ON a.publisherID = p.ID
	  WHERE a.ID % 2 = 0 


	/*allbooks tablosunda toplam  birden çok kitap'ı olan kaç yazar olduğunu hesaplayan sorgudur.*/
	SELECT COUNT(writerName) - COUNT(DISTINCT(writerID)) AS 'Listede Birden Çok Kitabı Olan Yazar Sayisi'  
	FROM allbooks

	/*allbooks tablosunda alfabetik olarak kitap adı en kısa olan kitabı sorgular */
	SELECT TOP 1 bookName,LEN(bookName) AS Uzunluk FROM allbooks 
	WHERE LEN(bookName) = (SELECT TOP 1 MIN(LEN(bookName)) AS Uzunluk FROM allbooks) 
        GROUP BY bookName ORDER BY bookName ASC


	/*allbooks tablosunda alfabetik olarak kitap adı en uzun olan kitabı sorgular */
    SELECT TOP 1 bookName,LEN(bookName) AS Uzunluk FROM allbooks 
  	WHERE LEN(bookName)=(SELECT TOP 1 MAX(LEN(bookName)) AS Uzunluk FROM allbooks) 
        GROUP BY bookName ORDER BY bookName ASC


	/*allBooks tablosunda isbnID 'de 4. karakteri 9 olmayan satırları döndüren sorgudur.*/
	SELECT* FROM allbooks WHERE isbnID NOT LIKE '___[9]%'


    /* allbooks tablosunda bookName sütunun'da tekrar etmeyen verilerde a,e,i,o,u harflerinin kitap isimlerinin hem başında hem de sonunda olmayan kitap isimlerini sorgular. */
	SELECT DISTINCT(bookName) FROM allbooks WHERE bookName NOT LIKE '[aeiom]%' AND bookName NOT LIKE '%[aeiom]'

   /*allbooks tablosunda her katagoride kaçar adet kitap olduğunu küçükten büyüğe sıralar. Bunu yaparken katagori adlarını alfabetik olarakta sıralar. 
	  Eğer alfabetik sıralamada aynı harfle başlayan katagoriler varsa bunları kendi içinde adet sayısına göre küçükten büyüğe sıralar. */
	SELECT CONCAT(bookTypeName,' ','katagorisinde',' ',COUNT(*), ' ','adet kitap vardır.') AS Katagori_Adetleri
        FROM allbooks
        GROUP BY bookTypeName
        ORDER BY  Katagori_Adetleri , bookTypeName ASC;

	/*Notlar:  

	INNER JOIN : İki ya da daha fazla tabloda ortak olan iki alandaki değerleri kontrol ederek tabloları birleştirir.
	  İki ya da daha fazla tabloda ortak olan iki alandaki değerleri kontrol ederek tabloları birleştirir. 
	  INNER JOIN, SQL sunucusunda varsayılan olan JOINdir. Yani INNER JOIN yerine sadece JOIN yazmak da yeterlidir. 
	  WHERE ifadesi kullanarak oluşturmak istenen sonuç tablosu filitrelenerek daha da özelleştirilebilir.

	COUNT : Kolonda veya sütunda hesaplanmak istenen sayıyı hesaplar.

	LIKE : Bir sütundaki belirli bir veriyi aramak için bir WHERE koşuluyla kullanılır. 
	  Aranmak istenen karakter % imleçi yardımıyla tasvir edilerek arama işlemi yapılır. 
	  Örneğin '%A' ifadesi A karakteri ile biten ifadeleri aramak için kullanılır.
	   'A%' ifadesi A karakteri ile başlayan ifadeleri aramak için kullanılır.
	   '%A%' ifadesi sağında ve solunda başka karakterlerinde olduğu ifadeleri arar. Örneğin: KAR kelimesini aramak için kullanılmalıdır.
	   '_a%' ifadesi ikinci harfi a olan ifadeleri bulur.
	   'a%o' ifadesi a ile başlayan o ile biten ifadeleri bulur.
	   'a__%' ifadesi a ile başlayan sonrasında sağında en azından 3 karakter olan ifadeleri bulur.

  NOT LIKE: Not like ifadesi LIKE ifadesinin tersi olarak çalışır. Sütunda arama yaparken aramadan hariç tutmak istediğimiz ifadeleri belirterek kullanırız.

	AS Operotörü : Sorgulama yaparken uzun ve karışık sütun isimlerini kolay kullanabilmek için kullanılan operotördür.
	  AS sayesinde sorgulama yaparken birden fazla tablo ile çalışırken tablolara takma isim vererek kullanım kolaylığı sağlanır.
	  Örnek olarak yukarda ınner joın ile yaptığımız sorgularda her tabloya isim vererek çalışılmıştır.
	  Ya da örneğin count ile bir işlem yapıyorsak çalıştığımız kolona anlaşırlık açısından isim vermek için kullanılır.

   WHERE : Bir koşul belirterek filtreleme yapmak için kullanılır. Where cümleciği koşul belirtmek için kullanılan bir komuttur.

   GROUP BY : Tabloda ki aynı değerlere sahip verileri gruplamamızı sağlar. Verileri bir veya daha fazla sütunla gruplamak için 
      toplama işlevleri kullanır. Örneğin COUNT, MAX, MIN, SUM, AVG gibi işlemlerle kullanılır.

   ORDER BY : verileri artan ya da azalan düzende sıralamak için kullanılır. Kayıtları varsayılan olarak artan sırada sıralar.
      Kayıtları azalan sırada sıralamak için DESC ifadesini kullanır.

   ASC : Listeyi artan sıraya göre sıralayacağımız belirtmek için kullanırız.

   DESC : Listeyi azalan sıraya göre sıralayacağımız belirtmek için kullanırız.

   SELF JOIN : Bir tablonun kendisiyle JOIN işlemi yapılmasına Self Join denir. Hiyerarşik verileri sorgulamak 
     veya aynı tablodaki satırları karşılaştırmak için kullanışlıdır.

   UNION ALL : İki tablodan birden kayıt çekmek için kullanılır. Ancak çekilecek kolonların aynı veri tipinden 
     olmaları gerekir. Ayrıca, çekilen veriler birbirlerinden farklı (distinct) olmalıdır.
	   Aynı olan verilerden yalnızca birisini seçer. 

   TOP : Sorgulanacak tabloda sıralı olarak istediğiniz satır sayısına göre çıktı döndürmeyi sağlar.

   DISTINCT : Veri tekrarını engellemek için kullanılır. Sorgulama yaparken aynı kolonda bulunan verilerde 
     veri tekrarının önüne geçerek veriyi bir kez döndürür.

   LEN : String bir verinin karakter sayısını almamızı sağlar.

   CRUD : CREATE ,READ, UPDATE ,DELETE işlemleri'dir.

   Stored Procedure : Veritabanında CRUD gibi işlemlerde, her seferinde kodu tekrar yazmamız ve derlememiz gerekmektedir. 
     Bu yüzden hem zaman hem de derleme açısından perormans kaybı oluşmaktadır. Bu gibi durumlarda Store Procedure, 
     ile bu sıkıntıların önüne geçeriz. Böylece her seferinde aynı işlemleri yapma gereksinimi duymadan zamandan tasarruf etmiş oluruz.
	 Kullanımı : CREATE PROCEDURE procedure_name 
                 AS 
                 BEGIN 
                 SORGU
                 END  

      Procedure bir kez CREATE yardımıyla oluşturulduktan sonra üstünde değişiklik yapılacak ise ALTER yardımıyla
	  bu değişiklikler yapılır.
	             ALTER PROCEDURE procedure_name 
                 AS 
                 BEGIN 
                 SORGU
                 END  

   EXECUTE : Ececute yardımıyla oluşturduğumuz Procedure' u çalıştırırız.

   MOD (%) : % işareti matematiksel ifade olarak bir sayının modunu almamıza yardımcı olur.

   AND-OR  : Where koşulunu kullanırken birden fazla koşul belirtmek için AND,OR yapıları kullanılır. AND kullanıldığında belirtilen koşulların tamamının sağlanması beklenir
         OR kullanıldığında koşullardan birinin sağlanması yeterlidir. Mantık ifadeleri mantığıyla işlem yapar.

   CONCAT : Bir veya daha fazla dizeyi-kolonu birleştirerek yeni bir dize oluşturmak için kullanılır.

			  */
	
