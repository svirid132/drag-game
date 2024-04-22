#ifndef FILE_H
#define FILE_H

#include <QDebug>
#include <QFile>
#include <QObject>


class File : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString readingData READ readingData NOTIFY readingDataChanged)

public:
    QString path() {
        return m_path;
    }
    QString readingData() {
        return m_readingData;
    }

    void setPath(const QString& s_path) {
        if (m_path == s_path) {
            return;
        }
        m_path = s_path;
        qDebug() << m_path;
        emit pathChanged();
    }

    Q_INVOKABLE bool read() {
        QFile file(m_path);
        if (!file.open(QIODevice::ReadOnly)) {
            qDebug() << "dont open";
            return false;
        }
        m_readingData = file.readAll();
        emit readingDataChanged();
        return true;
    }

signals:
    void pathChanged();
    void readingDataChanged();

private:
    QString m_path = "";
    QString m_readingData = "";

    QFile file;
};

#endif // FILE_H
