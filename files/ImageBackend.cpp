0001 /*
0002     SPDX-FileCopyrightText: 2007 Paolo Capriotti <p.capriotti@gmail.com>
0003     SPDX-FileCopyrightText: 2007 Aaron Seigo <aseigo@kde.org>
0004     SPDX-FileCopyrightText: 2008 Petri Damsten <damu@iki.fi>
0005     SPDX-FileCopyrightText: 2008 Alexis Ménard <darktears31@gmail.com>
0006     SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
0007     SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
0008     SPDX-FileCopyrightText: 2019 David Redondo <kde@david-redondo.de>
0009 
0010     SPDX-License-Identifier: GPL-2.0-or-later
0011 */
0012 
0013 #include "imagebackend.h"
0014 
0015 #include <math.h>
0016 
0017 #include <QDir>
0018 #include <QFileInfo>
0019 #include <QGuiApplication>
0020 #include <QImageReader>
0021 #include <QMimeDatabase>
0022 #include <QScreen>
0023 #include <QStandardPaths>
0024 
0025 #include <KLocalizedString>
0026 
0027 #include "model/imageproxymodel.h"
0028 #include "slidefiltermodel.h"
0029 #include "slidemodel.h"
0030 
0031 ImageBackend::ImageBackend(QObject *parent)
0032     : QObject(parent)
0033     , m_targetSize(qGuiApp->primaryScreen()->size() * qGuiApp->primaryScreen()->devicePixelRatio())
0034 {
0035     connect(&m_timer, &QTimer::timeout, this, &ImageBackend::nextSlide);
0036 }
0037 
0038 ImageBackend::~ImageBackend()
0039 {
0040 }
0041 
0042 void ImageBackend::classBegin()
0043 {
0044 }
0045 
0046 void ImageBackend::componentComplete()
0047 {
0048     m_ready = true;
0049 
0050     // MediaProxy will handle SingleImage case
0051     if (m_usedInConfig) {
0052         ensureWallpaperModel();
0053         ensureSlideshowModel();
0054     } else {
0055         startSlideshow();
0056     }
0057 }
0058 
0059 QString ImageBackend::image() const
0060 {
0061     return m_image.toString();
0062 }
0063 
0064 void ImageBackend::setImage(const QString &url)
0065 {
0066     if (url.isEmpty() || m_image == QUrl::fromUserInput(url)) {
0067         return;
0068     }
0069 
0070     m_image = QUrl::fromUserInput(url);
0071     Q_EMIT imageChanged();
0072 }
0073 
0074 ImageBackend::RenderingMode ImageBackend::renderingMode() const
0075 {
0076     return m_mode;
0077 }
0078 
0079 void ImageBackend::setRenderingMode(RenderingMode mode)
0080 {
0081     if (mode == m_mode) {
0082         return;
0083     }
0084 
0085     m_mode = mode;
0086     Q_EMIT renderingModeChanged();
0087 
0088     startSlideshow();
0089 }
0090 
0091 SortingMode::Mode ImageBackend::slideshowMode() const
0092 {
0093     return m_slideshowMode;
0094 }
0095 
0096 void ImageBackend::setSlideshowMode(SortingMode::Mode slideshowMode)
0097 {
0098     if (slideshowMode == m_slideshowMode) {
0099         return;
0100     }
0101 
0102     m_slideshowMode = slideshowMode;
0103 
0104     startSlideshow();
0105 }
0106 
0107 bool ImageBackend::slideshowFoldersFirst() const
0108 {
0109     return m_slideshowFoldersFirst;
0110 }
0111 
0112 void ImageBackend::setSlideshowFoldersFirst(bool slideshowFoldersFirst)
0113 {
0114     if (slideshowFoldersFirst == m_slideshowFoldersFirst) {
0115         return;
0116     }
0117 
0118     m_slideshowFoldersFirst = slideshowFoldersFirst;
0119 
0120     startSlideshow();
0121 }
0122 
0123 QSize ImageBackend::targetSize() const
0124 {
0125     return m_targetSize.value();
0126 }
0127 
0128 void ImageBackend::setTargetSize(const QSize &size)
0129 {
0130     Q_ASSERT(size.isValid());
0131     m_targetSize = size;
0132 }
0133 
0134 QAbstractItemModel *ImageBackend::wallpaperModel() const
0135 {
0136     Q_ASSERT(m_mode == SingleImage);
0137     return m_model;
0138 }
0139 
0140 void ImageBackend::ensureWallpaperModel()
0141 {
0142     if (m_model || m_mode != SingleImage) {
0143         return;
0144     }
0145 
0146     m_model = new ImageProxyModel({}, QBindable<QSize>(&m_targetSize), QBindable<bool>(&m_usedInConfig), this);
0147     m_loading.setBinding(m_model->loading().makeBinding());
0148 
0149     Q_EMIT wallpaperModelChanged();
0150 }
0151 
0152 void ImageBackend::ensureSlideshowModel()
0153 {
0154     if (m_slideshowModel || m_mode != SlideShow) {
0155         return;
0156     }
0157 
0158     m_slideshowModel = new SlideModel(QBindable<QSize>(&m_targetSize), QBindable<bool>(&m_usedInConfig), this);
0159     m_slideshowModel->setUncheckedSlides(m_uncheckedSlides);
0160     m_loading.setBinding(m_slideshowModel->loading().makeBinding());
0161 
0162     m_slideFilterModel = new SlideFilterModel(QBindable<bool>(&m_usedInConfig), //
0163                                               QBindable<SortingMode::Mode>(&m_slideshowMode), //
0164                                               QBindable<bool>(&m_slideshowFoldersFirst), //
0165                                               this);
0166     // setSourceModel(...) must be done in backgroundsFound() to generate a complete random order
0167 
0168     connect(this, &ImageBackend::uncheckedSlidesChanged, m_slideFilterModel, &SlideFilterModel::invalidateFilter);
0169     connect(m_slideshowModel, &SlideModel::dataChanged, this, &ImageBackend::slotSlideModelDataChanged);
0170 
0171     if (m_usedInConfig) {
0172         // When not used in config, slide paths are set in startSlideshow()
0173         m_slideshowModel->setSlidePaths(m_slidePaths);
0174         if (m_slideshowModel->loading().value()) {
0175             connect(m_slideshowModel, &SlideModel::done, this, &ImageBackend::backgroundsFound);
0176         } else {
0177             // In case it loads immediately
0178             m_slideFilterModel->setSourceModel(m_slideshowModel);
0179         }
0180     }
0181 
0182     Q_EMIT slideFilterModelChanged();
0183 }
0184 
0185 void ImageBackend::saveCurrentWallpaper()
0186 {
0187     if (!m_ready || m_usedInConfig || m_mode != RenderingMode::SlideShow || m_configMap.isNull() || !m_image.isValid()) {
0188         return;
0189     }
0190 
0191     QMetaObject::invokeMethod(this, "writeImageConfig", Qt::QueuedConnection, Q_ARG(QString, m_image.toString()));
0192 }
0193 
0194 QAbstractItemModel *ImageBackend::slideFilterModel() const
0195 {
0196     Q_ASSERT(m_mode == SlideShow);
0197     return m_slideFilterModel;
0198 }
0199 
0200 int ImageBackend::slideTimer() const
0201 {
0202     return m_delay;
0203 }
0204 
0205 void ImageBackend::setSlideTimer(int time)
0206 {
0207     if (time == m_delay) {
0208         return;
0209     }
0210 
0211     m_delay = time;
0212     Q_EMIT slideTimerChanged();
0213 
0214     startSlideshow();
0215 }
0216 
0217 QStringList ImageBackend::slidePaths() const
0218 {
0219     return m_slidePaths;
0220 }
0221 
0222 void ImageBackend::setSlidePaths(const QStringList &slidePaths)
0223 {
0224     if (slidePaths == m_slidePaths) {
0225         return;
0226     }
0227 
0228     m_slidePaths = slidePaths;
0229     m_slidePaths.removeAll(QString());
0230 
0231     if (!m_slidePaths.isEmpty()) {
0232         // Replace 'preferred://wallpaperlocations' with real paths
0233         const auto it = std::remove_if(m_slidePaths.begin(), m_slidePaths.end(), [](const QString &path) {
0234             return path == QLatin1String("preferred://wallpaperlocations");
0235         });
0236 
0237         if (it != m_slidePaths.end()) {
0238             m_slidePaths.erase(it, m_slidePaths.end());
0239             m_slidePaths << QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, QStringLiteral("wallpapers/"), QStandardPaths::LocateDirectory);
0240         }
0241     }
0242     if (!m_usedInConfig) {
0243         startSlideshow();
0244     } else if (m_slideshowModel) {
0245         // When used in config, m_slideshowModel can be nullptr when the image wallpaper is being used.
0246         m_slideshowModel->setSlidePaths(m_slidePaths);
0247     }
0248     Q_EMIT slidePathsChanged();
0249 }
0250 
0251 bool ImageBackend::addSlidePath(const QUrl &url)
0252 {
0253     Q_ASSERT(m_mode == SlideShow);
0254     if (url.isEmpty()) {
0255         return false;
0256     }
0257 
0258     QString path = url.toLocalFile();
0259 
0260     // If path is a file, use its parent folder.
0261     const QFileInfo info(path);
0262 
0263     if (info.isFile()) {
0264         path = info.dir().absolutePath();
0265     }
0266 
0267     const QStringList results = m_slideshowModel->addDirs({path});
0268 
0269     if (results.empty()) {
0270         return false;
0271     }
0272 
0273     m_slidePaths.append(results);
0274     Q_EMIT slidePathsChanged();
0275 
0276     return true;
0277 }
0278 
0279 void ImageBackend::removeSlidePath(const QString &path)
0280 {
0281     Q_ASSERT(m_mode == SlideShow);
0282 
0283     /* BUG 461003 check path is in the config*/
0284     m_slideshowModel->removeDir(path);
0285 
0286     if (m_slidePaths.removeOne(path)) {
0287         Q_EMIT slidePathsChanged();
0288     }
0289 }
0290 
0291 void ImageBackend::startSlideshow()
0292 {
0293     if (!m_ready || m_usedInConfig || m_mode != SlideShow || m_pauseSlideshow) {
0294         return;
0295     }
0296     // populate background list
0297     m_timer.stop();
0298     ensureSlideshowModel();
0299     m_slideFilterModel->setSourceModel(nullptr);
0300     connect(m_slideshowModel, &SlideModel::done, this, &ImageBackend::backgroundsFound);
0301     m_slideshowModel->setSlidePaths(m_slidePaths);
0302     // TODO: what would be cool: paint on the wallpaper itself a busy widget and perhaps some text
0303     // about loading wallpaper slideshow while the thread runs
0304 }
0305 
0306 void ImageBackend::backgroundsFound()
0307 {
0308     disconnect(m_slideshowModel, &SlideModel::done, this, nullptr);
0309 
0310     // setSourceModel must be called after the model is loaded to generate a complete random order
0311     Q_ASSERT(!m_slideFilterModel->sourceModel());
0312     m_slideFilterModel->setSourceModel(m_slideshowModel);
0313 
0314     if (m_slideFilterModel->rowCount() == 0 || m_usedInConfig) {
0315         return;
0316     }
0317 
0318     // start slideshow
0319     m_slideFilterModel->sort(0);
0320     m_currentSlide = m_configMap.isNull() || m_slideshowMode == SortingMode::Random
0321         ? -1
0322         : m_slideFilterModel->indexOf(m_configMap->value(QStringLiteral("Image")).toString()) - 1;
0323     nextSlide();
0324 }
0325 
0326 QString ImageBackend::nameFilters() const
0327 {
0328     QStringList imageGlobPatterns;
0329     QMimeDatabase db;
0330     const auto supportedMimeTypes = QImageReader::supportedMimeTypes();
0331     for (const QByteArray &mimeType : supportedMimeTypes) {
0332         QMimeType mime(db.mimeTypeForName(QString::fromLatin1(mimeType)));
0333         imageGlobPatterns << mime.globPatterns();
0334     }
0335     // i18n people, this isn't a "word puzzle". there is a specific string format for QFileDialog::setNameFilters
0336     return i18n("Image Files") + QLatin1String(" (") + imageGlobPatterns.join(QLatin1Char(' ')) + QLatin1Char(')');
0337 }
0338 
0339 QQmlPropertyMap *ImageBackend::configMap() const
0340 {
0341     return m_configMap.data();
0342 }
0343 
0344 void ImageBackend::setConfigMap(QQmlPropertyMap *configMap)
0345 {
0346     if (configMap == m_configMap.data()) {
0347         return;
0348     }
0349 
0350     m_configMap = configMap;
0351     Q_EMIT configMapChanged();
0352 
0353     if (!m_configMap.isNull()) {
0354         Q_ASSERT(m_configMap->contains(QStringLiteral("Image")));
0355     }
0356 
0357     connect(m_configMap, &QQmlPropertyMap::valueChanged, this, [this](const QString &key, const QVariant & /* value */) {
0358         if (key == QStringLiteral("Image")) {
0359             Q_EMIT configMapChanged();
0360         }
0361     });
0362 
0363     saveCurrentWallpaper();
0364 }
0365 
0366 QString ImageBackend::addUsersWallpaper(const QUrl &url)
0367 {
0368     Q_ASSERT(m_mode == SingleImage);
0369     ensureWallpaperModel(); // The model is not created by default when used in desktop
0370     auto results = m_model->addBackground(url.isLocalFile() ? url.toLocalFile() : url.toString());
0371 
0372     if (!m_usedInConfig) {
0373         m_model->commitAddition();
0374         m_model->deleteLater();
0375         m_model = nullptr;
0376     }
0377 
0378     if (results.empty()) {
0379         return QString();
0380     }
0381 
0382     Q_EMIT settingsChanged();
0383 
0384     return results.at(0);
0385 }
0386 
0387 void ImageBackend::nextSlide()
0388 {
0389     const int rowCount = m_slideFilterModel->rowCount();
0390 
0391     if (!m_ready || m_usedInConfig || rowCount == 0) {
0392         return;
0393     }
0394     int previousSlide = m_currentSlide;
0395     QString previousPath;
0396     if (previousSlide >= 0) {
0397         previousPath = m_slideFilterModel->index(m_currentSlide, 0).data(ImageRoles::PackageNameRole).toString();
0398     }
0399     if (m_currentSlide >= rowCount - 1 /* ">" in case the last wallpaper is deleted before */ || m_currentSlide < 0) {
0400         m_currentSlide = 0;
0401     } else {
0402         m_currentSlide += 1;
0403     }
0404     // We are starting again - avoid having the same random order when we restart the slideshow
0405     if (m_slideshowMode == SortingMode::Random && m_currentSlide == 0) {
0406         m_slideFilterModel->invalidate();
0407     }
0408     QString next = m_slideFilterModel->index(m_currentSlide, 0).data(ImageRoles::PackageNameRole).toString();
0409     // And  avoid showing the same picture twice
0410     if (previousSlide == rowCount - 1 && previousPath == next && rowCount > 1) {
0411         m_currentSlide += 1;
0412         next = m_slideFilterModel->index(m_currentSlide, 0).data(ImageRoles::PackageNameRole).toString();
0413     }
0414     m_timer.stop();
0415     m_timer.start(m_delay * 1000);
0416     if (next.isEmpty()) {
0417         m_image = QUrl::fromLocalFile(previousPath);
0418     } else {
0419         m_image = QUrl::fromLocalFile(next);
0420         Q_EMIT imageChanged();
0421     }
0422 
0423     saveCurrentWallpaper();
0424 }
0425 
0426 void ImageBackend::slotSlideModelDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QList<int> &roles)
0427 {
0428     Q_UNUSED(bottomRight);
0429 
0430     if (!topLeft.isValid()) {
0431         return;
0432     }
0433 
0434     if (roles.contains(ImageRoles::ToggleRole)) {
0435         if (topLeft.data(ImageRoles::ToggleRole).toBool()) {
0436             m_uncheckedSlides.removeOne(topLeft.data(ImageRoles::PackageNameRole).toString());
0437         } else {
0438             m_uncheckedSlides.append(topLeft.data(ImageRoles::PackageNameRole).toString());
0439         }
0440 
0441         Q_EMIT uncheckedSlidesChanged();
0442     }
0443 }
0444 
0445 QStringList ImageBackend::uncheckedSlides() const
0446 {
0447     return m_uncheckedSlides;
0448 }
0449 
0450 void ImageBackend::setUncheckedSlides(const QStringList &uncheckedSlides)
0451 {
0452     if (uncheckedSlides == m_uncheckedSlides) {
0453         return;
0454     }
0455     m_uncheckedSlides = uncheckedSlides;
0456 
0457     if (m_slideshowModel) {
0458         m_slideshowModel->setUncheckedSlides(m_uncheckedSlides);
0459     }
0460 
0461     Q_EMIT uncheckedSlidesChanged();
0462     startSlideshow();
0463 }
0464 
0465 bool ImageBackend::pauseSlideshow() const
0466 {
0467     return m_pauseSlideshow;
0468 }
0469 
0470 void ImageBackend::setPauseSlideshow(bool pauseSlideshow)
0471 {
0472     if (m_pauseSlideshow == pauseSlideshow) {
0473         return;
0474     }
0475 
0476     m_pauseSlideshow = pauseSlideshow;
0477     Q_EMIT pauseSlideshowChanged();
0478 
0479     if (!m_slideFilterModel) {
0480         return;
0481     }
0482 
0483     if (pauseSlideshow && m_timer.isActive()) {
0484         // Pause timer and store the remaining time
0485         m_remainingTime = m_timer.remainingTimeAsDuration();
0486         m_timer.stop();
0487     } else if (!pauseSlideshow && !m_timer.isActive()) {
0488         if (m_slideFilterModel->rowCount() > 0) {
0489             // Resume from the last point
0490             m_timer.start(m_remainingTime.value_or(std::chrono::seconds(m_delay)));
0491             m_remainingTime.reset();
0492         } else {
0493             // Start a new slideshow
0494             startSlideshow();
0495         }
0496     }
0497 }
0498 
0499 bool ImageBackend::loading() const
0500 {
0501     return m_loading;
0502 }