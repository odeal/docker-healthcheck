###Giriş

Bu yazıda mümkün olduğunca Türkçe kullanmaya çalışacağım. Olası terimlerin yanında parantez içerisinde sektör içinde kullanılan halini belirteceğim.  

Bir çoğumuz "**o kod bende çalışıyor bu durum sistemcinin suçu**" durumuyla karşılaşmıştır. Ürün geliştirilirken geliştirme ortamında farkında olmadan ya da olarak bulundurduğumuz bazı bağımlılıklar ve kütüphaneler ile çoğu kodumuz kendi makinemizde ayağa kalkabilmektedir. Ancak müşteriye hitap eden gerçek ortamda çoğu zaman sistemler minimal şekilde kurulur ve bu durum sürprizlere açıktır. İnsan hatası veya bağımlılıkların yönetimiyle ilgili olsun bu durumu aşmanın en temiz yolu kodumuzu tıpkı sıfır sunucuda çalışacakmışcasına ayarlamak üzere bir sanal makine üzerinde test etmektir.  

Docker, günümüz teknoloji dünyasında makine sanallaştırma işleminin sektör standardı haline gelmiştir. Bilinen çoğu platform artık Docker imajlarını standart olarak desteklemekte, istenildiği gibi ölçekleyebilmekte veyahut küme _(cluster)_ içerisinde düğümden düğüme _(node)_ çok kolay bir şekilde transfer edebilmektedir. Bu da DevOps tarafındaki arkadaşların çok işine yaramaktadır. Bu yazıda Docker'e değinmeyeceğiz, o sebepten bu bölümü kısa tutuyorum.

###Amaç

Geliştirici _(developer)_ arkadaşlarımız sürekli yenilikler geliştirip DevOps arkadaşlarımız da bunu müteakiben versiyonlar çıkmaktadır _(deployment)_. Hepimizin bildiği üzere versiyon çıkma işi platformda o an koşan imajın yerine yeni bir imaj yerleştirmek suretiyle yapılmaktadır. Bu esnada yeni imajımız ayağa kalkana kadar olan süre boyunca kesinti _(downtime)_ yaşayacağız. O sebepten muhtemelen bu tip versiyon yükseltme işleri için uykumuzdan ya da sosyal yaşantımızdan fedakarlık etmekteyiz.

###Docker Sağlık Kontrolü _(healthcheck)_

Versiyon değiştirme işinde arada kalan kesintiyi bertaraf etmek için imajlarımıza birer sağlık kontrolü ekleyebiliriz. Bunu eklemenin başka türlü de faydaları az değil ancak ben burada kesinti süresini bertaraf etme maksatlı anlatacağım.

Örneğimde Spring Boot Actuator ile gelen healthcheck modülünü kullandım. Spring, bu sağlık denetimini kendi içerisinde yapıp durumu bildirebilmekte, bize fazla iş bırakmamakta. Spring için olanı interaktif olabildiği veritabanı, redis bağlantısı gibi durumların kontrolü konusunda da yardımcı olabilmekte. Siz de kendi platformunuzda belli başlı kontroller yapıp periyodik olarak yoklayabilirsiniz. Kendi platformunuzda da (.net, node.js, php vb.) konuyla ilgili bileşenler bulabilirsiniz. Genel mantık, bir endpoint yaratıp, uygulamanız için hayati bileşenlerin kontrolünü yaptırıp her şey düzgün ise http 200 yanıtı dönmek.  

Sağlık kontrolü için Dockerfile dosyasına eklenecek satır şuna benzemektedir:

```
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s CMD curl --fail http://localhost:8080/actuator/health || exit 1
```

**interval:** Denetimin ne sıklıkta yapılacağını belirleyen parametredir. **start-period** süresi geçildikten sonra imaj ayakta olduğu sürece belirlenen süre boyunca çalıştırılmaktadır. Örnekte 30 saniyede bir çalışacak şekilde ayarlı.  
**timeout:** Denetim için verilen komutun süresini belirliyoruz. Örnekte 5 saniyeden uzun sürerse işler yolunda değildir anlamına gelir. 3 defa başarısız olması halinde Docker imajın çalışmasını sonlandıracaktır.  
**start-period:** Denetimin imaj ayağa kalktıktan ne kadar süre sonra başlayacağını belirleyen parametre. Örnekte 1 dakika sonra kendi sağlığını denetlemeye çalışacak.  
**CMD:** Sağlık denetimi için çalıştırılacak komut. Benim örneğimde eğer ters bir durum varsa exit 1 ile çık komutu verdim.

###Dezavantajlar
- Geç ayağa kalkan bir uygulamanız var ise start-period parametresi üzerinde değişiklik yapmalısınız.
- Sağlık denetimi olan imajlar sağlıklı _(healthy)_ durumuna düşene kadar başlatılıyor _(starting)_ durumunda kalacaktır, platformunuz (swarm, kubernetes, vb.) bu imaja trafik yönlendirmeyecek, eski çalışan halinde kalmaya devam edecektir. Bu, düğümü ilk başlattığınız durumlarda _(cold start)_ kesinti süresini uzatacaktır.

###Sonuç
Bir çok konuda fayda sağlayan Docker sağlık denetimine versiyon değişimi esnasındaki kesintileri azaltma konusunda ufkum çerçevesinde değinmeye çalıştım. Fikirlerinizi, eksiklikleri yorum kısmında belirtebilirsiniz, kesintisiz günler diliyorum.