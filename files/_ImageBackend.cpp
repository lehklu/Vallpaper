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
0073 
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
0139 
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

0242     if (!m_usedInConfig) {
0243         startSlideshow();
0244     } else if (m_slideshowModel) {
0245         // When used in config, m_slideshowModel can be nullptr when the image wallpaper is being used.
0246         m_slideshowModel->setSlidePaths(m_slidePaths);
0247     }
0248     Q_EMIT slidePathsChanged();
0249 }
0250 
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
0338 
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