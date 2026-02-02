package org.apache.hadoop.hive.ql.exec;

import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.hive.common.classification.InterfaceAudience;
import org.apache.hadoop.hive.common.classification.InterfaceStability;
import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.hive.ql.metadata.Hive;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.session.SessionState;

import java.util.List;


/**
 * Defines how Hive will commit data to its final directory.
 */
@InterfaceAudience.Private
@InterfaceStability.Unstable
public interface DataCommitter {

  void moveFile(Path sourcePath, Path targetPath, boolean isDfsDir, HiveConf conf,
                SessionState.LogHelper console) throws HiveException;

  void copyFiles(HiveConf conf, Path srcf, Path destf, FileSystem fs, boolean isSrcLocal,
                 boolean isAcidIUD, boolean isOverwrite, List<Path> newFiles, boolean isBucketed,
                 boolean isFullAcidTable, boolean isManaged) throws HiveException;

  void replaceFiles(Path tablePath, Path srcf, Path destf, Path oldPath, HiveConf conf,
                    boolean isSrcLocal, boolean purge, List<Path> newFiles,
                    PathFilter deletePathFilter, boolean isNeedRecycle, boolean isManaged,
                    Hive hive) throws HiveException;
}
